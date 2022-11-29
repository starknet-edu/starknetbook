import sys

sys.path.append("../../")

from constraints import polynomial_constraints
from stark101utils.python.field import FieldElement

cp, cp_eval, cp_root, eval_domain = polynomial_constraints()
print("GOT IT: ")
