import sys

sys.path.append('../../')

from stark101utils.python.field import FieldElement
from constraints import polynomial_constraints

cp, cp_eval, cp_root, eval_domain = polynomial_constraints()
print("GOT IT: ")