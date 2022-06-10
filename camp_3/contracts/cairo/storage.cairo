%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write

####################
# STORAGE VARIABLES
####################
@storage_var
func test_store() -> (res : felt):
end


