###############################################################################
# Copyright 2019 StarkWare Industries Ltd.                                    #
#                                                                             #
# Licensed under the Apache License, Version 2.0 (the "License").             #
# You may not use this file except in compliance with the License.            #
# You may obtain a copy of the License at                                     #
#                                                                             #
# https://www.starkware.co/open-source-license/                               #
#                                                                             #
# Unless required by applicable law or agreed to in writing,                  #
# software distributed under the License is distributed on an "AS IS" BASIS,  #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
# See the License for the specific language governing permissions             #
# and limitations under the License.                                          #
###############################################################################


import inspect
from hashlib import sha256

from stark101utils.python.field import FieldElement


def serialize(obj):
    """
    Serializes an object into a string.
    """
    if isinstance(obj, (list, tuple)):
        return ','.join(map(serialize, obj))
    return obj._serialize_()


class Channel(object):
    """
    A Channel instance can be used by a prover or a verifier to preserve the semantics of an
    interactive proof system, while under the hood it is in fact non-interactive, and uses Sha256
    to generate randomness when this is required.
    It allows writing string-form data to it, and reading either random integers of random
    FieldElements from it.
    """

    def __init__(self):
        self.state = '0'
        self.proof = []

    def send(self, s):
        self.state = sha256((self.state + s).encode()).hexdigest()
        self.proof.append(f'{inspect.stack()[0][3]}:{s}')

    def receive_random_int(self, min, max, show_in_proof=True):
        """
        Emulates a random integer sent by the verifier in the range [min, max] (including min and
        max).
        """

        # Note that when the range is close to 2^256 this does not emit a uniform distribution,
        # even if sha256 is uniformly distributed.
        # It is, however, close enough for this tutorial's purposes.
        num = min + (int(self.state, 16) % (max - min + 1))
        self.state = sha256((self.state).encode()).hexdigest()
        if show_in_proof:
            self.proof.append(f'{inspect.stack()[0][3]}:{num}')
        return num

    def receive_random_field_element(self):
        """
        Emulates a random field element sent by the verifier.
        """
        num = self.receive_random_int(0, FieldElement.k_modulus - 1, show_in_proof=False)
        self.proof.append(f'{inspect.stack()[0][3]}:{num}')
        return FieldElement(num)
