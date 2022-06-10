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


from hashlib import sha256
from math import log2, ceil

from stark101utils.python.field import FieldElement


class MerkleTree(object):
    """
    A simple and naive implementation of an immutable Merkle tree.
    """

    def __init__(self, data):
        assert isinstance(data, list)
        assert len(data) > 0, 'Cannot construct an empty Merkle Tree.'
        num_leaves = 2 ** ceil(log2(len(data)))
        self.data = data + [FieldElement(0)] * (num_leaves - len(data))
        self.height = int(log2(num_leaves))
        self.facts = {}
        self.root = self.build_tree()

    def get_authentication_path(self, leaf_id):
        assert 0 <= leaf_id < len(self.data)
        node_id = leaf_id + len(self.data)
        cur = self.root
        decommitment = []
        # In a Merkle Tree, the path from the root to a leaf, corresponds to the the leaf id's
        # binary representation, starting from the second-MSB, where '0' means 'left', and '1' means
        # 'right'.
        # We therefore iterate over the bits of the binary representation - skipping the '0b'
        # prefix, as well as the MSB.
        for bit in bin(node_id)[3:]:
            cur, auth = self.facts[cur]
            if bit == '1':
                auth, cur = cur, auth
            decommitment.append(auth)
        return decommitment

    def build_tree(self):
        return self.recursive_build_tree(1)

    def recursive_build_tree(self, node_id):
        if node_id >= len(self.data):
            # A leaf.
            id_in_data = node_id - len(self.data)
            leaf_data = str(self.data[id_in_data])
            h = sha256(leaf_data.encode()).hexdigest()
            self.facts[h] = leaf_data
            return h
        else:
            # An internal node.
            left = self.recursive_build_tree(node_id * 2)
            right = self.recursive_build_tree(node_id * 2 + 1)
            h = sha256((left + right).encode()).hexdigest()
            self.facts[h] = (left, right)
            return h


def verify_decommitment(leaf_id, leaf_data, decommitment, root):
    leaf_num = 2 ** len(decommitment)
    node_id = leaf_id + leaf_num
    cur = sha256(str(leaf_data).encode()).hexdigest()
    for bit, auth in zip(bin(node_id)[3:][::-1], decommitment[::-1]):
        if bit == '0':
            h = cur + auth
        else:
            h = auth + cur
        cur = sha256(h.encode()).hexdigest()
    return cur == root
