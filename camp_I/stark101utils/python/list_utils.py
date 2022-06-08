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


from itertools import dropwhile, starmap, zip_longest


def remove_trailing_elements(list_of_elements, element_to_remove):
    return list(dropwhile(lambda x: x == element_to_remove, list_of_elements[::-1]))[::-1]


def two_lists_tuple_operation(f, g, operation, fill_value):
    return list(starmap(operation, zip_longest(f, g, fillvalue=fill_value)))


def scalar_operation(list_of_elements, operation, scalar):
    return [operation(c, scalar) for c in list_of_elements]
