# WORD Size is 64 bit
CAIRO_WORD=0x400680017fff8000
WORD_BITS=list(bin(CAIRO_WORD))[2:]
# Convert to little
WORD_BITS=WORD_BITS[::-1]

# example: 
# OFF(dst):  0 1 1 1 1 1 1 1 1 1 1 1 1
# OFF(op0):  1 1 0 1 1 1 1 1 1 1 1 1 1
# OFF(op1):  1 1 1 1 1 0 1 1 1 1 1 1 1
# DST Reg:  1
# OP0 Reg:  1
# OP1 Src:  0 1 0
# Res_Logic:  0 0
# PC_Update:  1 0 0
# AP_Update:  0 0
# Opcode:  0 1

#three 16-bit signed integer offsets
print("OFF(dst): ", " ".join(WORD_BITS[:13]))
print("OFF(op0): ", " ".join(WORD_BITS[13:26]))
print("OFF(op1): ", " ".join(WORD_BITS[26:39]))
print("DST Reg: ", " ".join(WORD_BITS[48:49]))
print("OP0 Reg: ", " ".join(WORD_BITS[49:50]))
print("OP1 Src: ", " ".join(WORD_BITS[50:53]))
print("Res_Logic: ", " ".join(WORD_BITS[53:55]))
print("PC_Update: ", " ".join(WORD_BITS[55:58]))
print("AP_Update: ", " ".join(WORD_BITS[58:60]))
print("Opcode: ", " ".join(WORD_BITS[60:63]))
