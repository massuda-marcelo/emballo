unit da32resc;
////////////////////////////////////////////////////////////////////////////////
//
//   NOTE: This unit is only a partial declaration of the libdisasm conversion,
//         and should NOT be included in any project using DISASM32.PAS. The
//         only purpose for this unit is to dump the huge tables out to an RC,
//         file, and then compile that RC file into a new .RES file to be used
//         by the DISASM32.PAS. The reason I did this it due to the fact that
//         you will be unable to debug the DISASM32.PAS if the tables are
//         included as constants (more that 64K of constant data).
//
////////////////////////////////////////////////////////////////////////////////
interface

uses
  Windows, SysUtils;

// Copied from extensions/arch.h in the bastard
const
  BIG_ENDIAN_ORD    =  0;
  LITTLE_ENDIAN_ORD =  1;

// Disassembler options
const
  IGNORE_NULLS      =  $01;        // Don't disassemble sequences of > 4 NULLs
  LEGACY_MODE       =  $02;        // E.g. 16-bit on Intel

// Operand and instruction types - Permissions
const
  OP_R              =  $01;        // Operand is READ
  OP_W              =  $02;        // Operand is WRITTEN
  OP_X              =  $04;        // Operand is EXECUTED

// Operand and instruction types - Types
const
  OP_UNK            =  $0000;      // Unknown operand
  OP_REG            =  $0100;      // Register
  OP_IMM            =  $0200;      // Immediate value
  OP_REL            =  $0300;      // Relative Address [offset from IP]
  OP_ADDR           =  $0400;      // Absolute Address
  OP_EXPR           =  $0500;      // Address Expression [e.g. SIB byte]
  OP_PTR            =  $0600;      // Operand is an Address containing a Pointer
  OP_OFF            =  $0700;      // Operand is an offset from a seg/selector

// Operand and instruction types - Modifiers
const
  OP_SIGNED         =  $00001000;  // Operand is signed
  OP_STRING         =  $00002000;  // Operand a string
  OP_CONST          =  $00004000;  // Operand is a constant
  OP_EXTRASEG       =  $00010000;  // Seg overrides
  OP_CODESEG        =  $00020000;
  OP_STACKSEG       =  $00030000;
  OP_DATASEG        =  $00040000;
  OP_DATA1SEG       =  $00050000;
  OP_DATA2SEG       =  $00060000;

// Operand and instruction types - Size
const
  OP_BYTE           =  $00100000;  // Operand is 8 bits/1 byte
  OP_HWORD          =  $00200000;  // Operand is .5 mach word (Intel 16 bits)
  OP_WORD           =  $00300000;  // Operand is 1 machine word (Intel 32 bits)
  OP_DWORD          =  $00400000;  // Operand is 2 mach words (Intel 64 bits)
  OP_QWORD          =  $00500000;  // Operand is 4 mach words (Intel 128 bits)
  OP_SREAL          =  $00600000;  // Operand is 32 bits/4 bytes
  OP_DREAL          =  $00700000;  // Operand is 64 bits/8 bytes
  OP_XREAL          =  $00800000;  // Operand is 40 bits/10 bytes
  OP_BCD            =  $00900000;  // Operand is 40 bits/10 bytes
  OP_SIMD           =  $00A00000;  // Operand is 128 bits/16 bytes
  OP_FPENV          =  $00B00000;  // Operand is 224 bits/28 bytes

// Operand masks
const
  OP_PERM_MASK      =  $00000007;  // Perms are NOT mutually exclusive
  OP_TYPE_MASK      =  $00000F00;  // Types are mututally exclusive
  OP_MOD_MASK       =  $000FF000;  // Mods are NOT mutually exclusive
  OP_SEG_MASK       =  $000F0000;  // Segs are NOT mutually exclusive
  OP_SIZE_MASK      =  $00F00000;  // Sizes are mutually exclusive
  OP_REG_MASK       =  $0000FFFF;  // Lower WORD is register ID
  OP_REGTBL_MASK    =  $FFFF0000;  // Higher word is register type [gen/dbg]

// Instruction types [groups]
const
  INS_EXEC		      =  $1000;
  INS_ARITH		   =  $2000;
  INS_LOGIC		   =  $3000;
  INS_STACK		   =  $4000;
  INS_COND		      =  $5000;
  INS_LOAD		      =  $6000;
  INS_ARRAY		   =  $7000;
  INS_BIT		      =  $8000;
  INS_FLAG		      =  $9000;
  INS_FPU		      =  $A000;
  INS_TRAPS		   =  $D000;
  INS_SYSTEM	      =  $E000;
  INS_OTHER		   =  $F000;

// INS_EXEC group
const
  INS_BRANCH	      =  INS_EXEC or $01;  // Unconditional branch
  INS_BRANCHCC	   =  INS_EXEC or $02;	// Conditional branch
  INS_CALL		      =  INS_EXEC or $03;	// Jump to subroutine
  INS_CALLCC	      =  INS_EXEC or $04;  // Jump to subroutine
  INS_RET		      =  INS_EXEC or $05;	// Return from subroutine
  INS_LOOP		      =  INS_EXEC or $06;	// Loop to local label

// INS_ARITH group
const
  INS_ADD 		      =  INS_ARITH or $01;
  INS_SUB		      =  INS_ARITH or $02;
  INS_MUL		      =  INS_ARITH or $03;
  INS_DIV		      =  INS_ARITH or $04;
  INS_INC		      =  INS_ARITH or $05; // Increment
  INS_DEC		      =  INS_ARITH or $06;	// Decrement
  INS_SHL		      =  INS_ARITH or $07;	// Shift right
  INS_SHR		      =  INS_ARITH or $08;	// Shift left
  INS_ROL		      =  INS_ARITH or $09;	// Rotate left
  INS_ROR		      =  INS_ARITH or $0A;	// Rotate right

// INS_LOGIC group
const
  INS_AND		      =  INS_LOGIC or $01;
  INS_OR		      =  INS_LOGIC or $02;
  INS_XOR		      =  INS_LOGIC or $03;
  INS_NOT		      =  INS_LOGIC or $04;
  INS_NEG		      =  INS_LOGIC or $05;

// INS_STACK group
const
  INS_PUSH		      =  INS_STACK or $01;
  INS_POP		      =  INS_STACK or $02;
  INS_PUSHREGS	   =  INS_STACK or $03; // Push register context
  INS_POPREGS	      =  INS_STACK or $04;	// Pop register context
  INS_PUSHFLAGS	   =  INS_STACK or $05;	// Push all flags
  INS_POPFLAGS	   =  INS_STACK or $06;	// Pop all flags
  INS_ENTER		   =  INS_STACK or $07;	// Enter stack frame
  INS_LEAVE		   =  INS_STACK or $08;	// Leave stack frame

// INS_COND group
const
  INS_TEST		      =  INS_COND or $01;
  INS_CMP		      =  INS_COND or $02;

// INS_LOAD group
const
  INS_MOV		      =  INS_LOAD or $01;
  INS_MOVCC		   =  INS_LOAD or $02;
  INS_XCHG		      =  INS_LOAD or $03;
  INS_XCHGCC	      =  INS_LOAD or $04;

// INS_ARRAY group
const
  INS_STRCMP	      =  INS_ARRAY or $01;
  INS_STRLOAD	      =  INS_ARRAY or $02;
  INS_STRMOV	      =  INS_ARRAY or $03;
  INS_STRSTOR	      =  INS_ARRAY or $04;
  INS_XLAT		      =  INS_ARRAY or $05;

// INS_BIT group
const
  INS_BITTEST	      =  INS_BIT or $01;
  INS_BITSET	      =  INS_BIT or $02;
  INS_BITCLR	      =  INS_BIT or $03;

// INS_FLAG group
const
  INS_CLEARCF	      =  INS_FLAG or $01;  // Clear Carry flag
  INS_CLEARZF	      =  INS_FLAG or $02;	// Clear Zero flag
  INS_CLEAROF	      =  INS_FLAG or $03;	// Clear Overflow flag
  INS_CLEARDF	      =  INS_FLAG or $04;	// Clear Direction flag
  INS_CLEARSF	      =  INS_FLAG or $05;	// Clear Sign flag
  INS_CLEARPF	      =  INS_FLAG or $06;	// Clear Parity flag
  INS_SETCF		   =  INS_FLAG or $07;
  INS_SETZF		   =  INS_FLAG or $08;
  INS_SETOF		   =  INS_FLAG or $09;
  INS_SETDF		   =  INS_FLAG or $0A;
  INS_SETSF		   =  INS_FLAG or $0B;
  INS_SETPF		   =  INS_FLAG or $0C;
  INS_TOGCF		   =  INS_FLAG or $10;  // Toggle
  INS_TOGZF		   =  INS_FLAG or $20;
  INS_TOGOF		   =  INS_FLAG or $30;
  INS_TOGDF		   =  INS_FLAG or $40;
  INS_TOGSF		   =  INS_FLAG or $50;
  INS_TOGPF		   =  INS_FLAG or $60;

// INS_FPU

// INS_TRAP
const
  INS_TRAP		      =  INS_TRAPS or $01;    // Generate trap
  INS_TRAPCC	      =  INS_TRAPS or $02;		// Conditional trap gen
  INS_TRET		      =  INS_TRAPS or $03;		// Return from trap
  INS_BOUNDS	      =  INS_TRAPS or $04;		// Gen bounds trap
  INS_DEBUG		   =  INS_TRAPS or $05;		// Gen breakpoint trap
  INS_TRACE		   =  INS_TRAPS or $06;		// Gen single step trap
  INS_INVALIDOP	   =  INS_TRAPS or $07;		// Gen invalid instruction
  INS_OFLOW		   =  INS_TRAPS or $08;		// Gen overflow trap

// INS_SYSTEM
const
  INS_HALT		      =  INS_SYSTEM or $01;   // Halt machine
  INS_IN		      =  INS_SYSTEM or $02;   // Input form port
  INS_OUT		      =  INS_SYSTEM or $03;	// Output to port
  INS_CPUID		   =  INS_SYSTEM or $04;	// Identify cpu

// INS_OTHER
const
  INS_NOP		      =  INS_OTHER or $01;
  INS_BCDCONV	      =  INS_OTHER or $02;	   // Convert to/from BCD
  INS_SZCONV	      =  INS_OTHER or $03;	   // Convert size of operand

// Instruction size
const
  INS_BYTE          =  $010000;             // Operand is  8 bits/1 byte
  INS_WORD          =  $020000;             // Operand is 16 bits/2 bytes
  INS_DWORD         =  $040000;             // Operand is 32 bits/4 bytes
  INS_QWORD         =  $080000;             // Operand is 64 bits/8 bytes

// Instruction modifiers
const
  INS_REPZ          =  $00100000;
  INS_REPNZ         =  $00200000;
  INS_LOCK          =  $00400000;           // Lock bus
  INS_DELAY         =  $00800000;           // Branch delay slot

// Masks
const
  INS_TYPE_MASK	   =  $0000FFFF;
  INS_GROUP_MASK	   =  $00001000;
  INS_SIZE_MASK     =  $000F0000;
  INS_MOD_MASK      =  $0FF00000;

// Code patterns
const
  FUNCTION_PROLOGUE =  $0001;
  FUNCTION_EPILOGUE =  $0002;

// These could reuse OP types, but those types are too general...
const
  ADDEXP_SCALE_MASK =  $000000FF;
  ADDEXP_INDEX_MASK =  $0000FF00;
  ADDEXP_BASE_MASK  =  $00FF0000;
  ADDEXP_DISP_MASK  =  $FF000000;
  ADDEXP_SCALE_OFFSET  =  0;
  ADDEXP_INDEX_OFFSET  =  8;
  ADDEXP_BASE_OFFSET   =  16;
  ADDEXP_DISP_OFFSET   =  24;
  ADDREXP_BYTE      =  $01;
  ADDREXP_WORD      =  $02;
  ADDREXP_DWORD     =  $03;
  ADDREXP_QWORD     =  $04;
  ADDREXP_REG       =  $10; // 0x00 implies non-register

// Pointless defines for fixing i386.c
const
  CODE_RVA          =  0;

// Register types
const
  REG_GENERAL	      =  $00000001;	      // General-purpose
  REG_INPUT		   =  $00000002;		   // Incoming args
  REG_OUTPUT	      =  $00000004;		   // Args to subroutines
  REG_LOCAL		   =  $00000008;		   // Local vars
  REG_FPU		      =  $00000010;		   // FPU reg
  REG_SEG		      =  $00000020;		   // Segment reg
  REG_SIMD		      =  $00000040;		   // Simd/mmx stuff
  REG_SYS		      =  $00000080;		   // CPU/OS internal reg
  REG_SP		      =  $00001000;	      // Stack pointer
  REG_FP		      =  $00002000;	      // Frame pointer
  REG_PC		      =  $00004000;	      // Program counter
  REG_RETADD	      =  $00008000;	      // Return address
  REG_CC		      =  $00010000;	      // Condition code
  REG_ZERO		      =  $00020000;	      // /dev/null register
  REG_RET		      =  $00040000;	      // Return value
  REG_ASRC		      =  $00100000;	      // Array source
  REG_ADEST		   =  $00200000;	      // Array dest
  REG_ACNT		      =  $00400000;	      // Array length/counter

////////////////////////////////////////////////////////////////////////////////
// Libdis.h Conversion
////////////////////////////////////////////////////////////////////////////////

// Formats
const
  NATIVE_SYNTAX     =  $00;
  INTEL_SYNTAX      =  $01;
  ATT_SYNTAX        =  $02;

////////////////////////////////////////////////////////////////////////////////
// I386.h Conversion
////////////////////////////////////////////////////////////////////////////////

// Opcode tables
const
  x86_MAIN          =  0;
  x86_0F            =  1;
  x86_80            =  2;

const
  REG_DWORD_OFFSET  =  0;
  REG_WORD_OFFSET   =  1 * 8;
  REG_BYTE_OFFSET   =  2 * 8;
  REG_MMX_OFFSET    =  3 * 8;
  REG_SIMD_OFFSET   =  4 * 8;
  REG_DEBUG_OFFSET  =  5 * 8;
  REG_CTRL_OFFSET   =  6 * 8;
  REG_TEST_OFFSET   =  7 * 8;
  REG_SEG_OFFSET    =  8 * 8;
  REG_FPU_OFFSET    =  9 * 8;
  REG_FLAGS_INDEX   =  10 * 8;
  REG_FPCTRL_INDEX  =  10 * 8 + 1;
  REG_FPSTATUS_INDEX=  10 * 8 + 2;
  REG_FPTAG_INDEX   =  10 * 8 + 3;
  REG_EIP_INDEX     =  10 * 8 + 4;
  REG_IP_INDEX      =  10 * 8 + 5;

const
  REG_DWORD_SIZE    =  4;
  REG_WORD_SIZE     =  2;
  REG_BYTE_SIZE     =  1;
  REG_MMX_SIZE      =  4;
  REG_SIMD_SIZE     =  4;
  REG_DEBUG_SIZE    =  4;
  REG_CTRL_SIZE     =  4;
  REG_TEST_SIZE     =  4;
  REG_SEG_SIZE      =  2;
  REG_FPU_SIZE      =  10;
  REG_FLAGS_SIZE    =  4;
  REG_FPCTRL_SIZE   =  2;
  REG_FPSTATUS_SIZE =  2;
  REG_FPTAG_SIZE    =  2;
  REG_EIP_SIZE      =  4;
  REG_IP_SIZE       =  2;

// Add TR LDTR [6 bytes] and IDTR GDTR (4bytes)

// The following dictate what ISAs to support - for now these do nothing
const
  ISA_8086          =  $00000010;
  ISA_80286         =  $00000020;
  ISA_80386         =  $00000040;
  ISA_80486         =  $00000080;
  ISA_PENTIUM       =  $00000100;
  ISA_PENTIUM_2     =  $00000200;
  ISA_PENTIUM_3     =  $00000400;
  ISA_PENTIUM_4     =  $00000800;
  ISA_K6            =  $00001000;
  ISA_K7            =  $00002000;
  ISA_ATHLON        =  $00004000;
  ISA_SIMD          =  $00010000;
  ISA_MMX           =  $00020000;
  ISA_3DNOW         =  $00040000;

////////////////////////////////////////////////////////////////////////////////
// I386_opcode.h Conversion
////////////////////////////////////////////////////////////////////////////////

// Instruction structure - used for reading opcode table
type
  Pinstr            =  ^instr;
  instr             =  packed record
     table:         Integer;
     mnemFlg:       Cardinal;
     destFlg:       Integer;
     srcFlg:        Integer;
     auxFlg:        Integer;
     cpu:           Integer;
     mnemonic:      Array [0..15] of Char;
     dest:          Integer;
     src:           Integer;
     aux:           Integer;
  end;
  TInstrArray       =  Array [0..255] of instr;
  PInstrArray       =  ^TInstrArray;

const
  MAX_INSTRUCTION_SIZE    =  20;

// Opcode Prefixes
const
  INSTR_PREFIX      =  $F0000000;

// Prefixes, same order as in the manual
const
  PREFIX_LOCK       =  $00100000;
  PREFIX_REPNZ      =  $00200000;
  PREFIX_REPZ       =  $00400000;
  PREFIX_REP        =  $00800000;
  PREFIX_REP_SIMD   =  $01000000;
  PREFIX_OP_SIZE    =  $02000000;
  PREFIX_ADDR_SIZE  =  $04000000;
  PREFIX_SIMD       =  $08000000;
  PREFIX_CS         =  $10000000;
  PREFIX_SS         =  $20000000;
  PREFIX_DS         =  $30000000;
  PREFIX_ES         =  $40000000;
  PREFIX_FS         =  $50000000;
  PREFIX_GS         =  $60000000;
  PREFIX_REG_MASK   =  $F0000000;

// The Flags That Time Forgot
const
  ARG_NONE          =  0;
  cpu_8086          =  $00001000;
  cpu_80286         =  $00002000;
  cpu_80386         =  $00003000;
  cpu_80387         =  $00004000;
  cpu_80486         =  $00005000;
  cpu_PENTIUM       =  $00006000;
  cpu_PENTPRO       =  $00007000;
  cpu_PENTMMX       =  $00008000;
  cpu_PENTIUM2      =  $00009000;

//Operand classifications, per dislib.h, go to 0x0900
const
  OPFLAGS_MASK      =  $0000FFFF;

// Operand Addressing Methods, per intel manual
const
  ADDRMETH_MASK     =  $00FF0000;

const
  ADDRMETH_A        =  $00010000;
  ADDRMETH_C        =  $00020000;
  ADDRMETH_D        =  $00030000;
  ADDRMETH_E        =  $00040000;
  ADDRMETH_F        =  $00050000;
  ADDRMETH_G        =  $00060000;
  ADDRMETH_I        =  $00070000;
  ADDRMETH_J        =  $00080000;
  ADDRMETH_M        =  $00090000;
  ADDRMETH_O        =  $000A0000;
  ADDRMETH_P        =  $000B0000;
  ADDRMETH_Q        =  $000C0000;
  ADDRMETH_R        =  $000D0000;
  ADDRMETH_S        =  $000E0000;
  ADDRMETH_T        =  $000F0000;
  ADDRMETH_V        =  $00100000;
  ADDRMETH_W        =  $00110000;
  ADDRMETH_X        =  $00120000;
  ADDRMETH_Y        =  $00130000;

// Operand Size Codings
const
  OP_SIZE_8         =  $00200000;
  OP_SIZE_16        =  $00400000;
  OP_SIZE_32        =  $00800000;

// Operand Types, per intel manual
const
  OPTYPE_MASK       =  $FF000000;

const
  OPTYPE_a          =  $01000000;
  OPTYPE_b          =  $02000000;
  OPTYPE_c          =  $03000000;
  OPTYPE_d          =  $04000000;
  OPTYPE_dq         =  $05000000;
  OPTYPE_p          =  $06000000;
  OPTYPE_pi         =  $07000000;
  OPTYPE_ps         =  $08000000;
  OPTYPE_q          =  $09000000;
  OPTYPE_s          =  $0A000000;
  OPTYPE_ss         =  $0B000000;
  OPTYPE_si         =  $0C000000;
  OPTYPE_v          =  $0D000000;
  OPTYPE_w          =  $0E000000;
  OPTYPE_m          =  $0F000000;     // To handle LEA

// Ones added for FPU instructions
const
  OPTYPE_fs	      =  $10000000;	   // Pointer to single-real
  OPTYPE_fd	      =  $20000000;	   // Pointer to double real
  OPTYPE_fe	      =  $30000000;	   // Pointer to extended real
  OPTYPE_fb	      =  $40000000;	   // Pointer to packed BCD
  OPTYPE_fv	      =  $50000000;	   // Pointer to FPU env: 14/28-bytes


// ModR/M, SIB - Convenience flags
const
  MODRM_EA          =  1;
  MODRM_reg         =  2;

// ModR/M flags
const
  MODRM_RM_SIB      =  $04;
  MODRM_RM_NOREG    =  $05;
  // if (MODRM.MOD_NODISP && MODRM.RM_NOREG) then just disp32
  MODRM_MOD_NODISP  =  $00;
  MODRM_MOD_DISP8   =  $01;
  MODRM_MOD_DISP32  =  $02;
  MODRM_MOD_NOEA    =  $03;

// SIB flags
const
  SIB_INDEX_NONE    =  $04;
  SIB_BASE_EBP      =  $05;
  SIB_SCALE_NOBASE  =  $00;

// Convenience struct for opcode tables
type
  Px86table         =  ^x86_table;
  x86_table         =  packed record
     table:         PInstrArray;
     shift:         Byte;
     mask:          Byte;
     minlim:        Byte;
     maxlim:        Byte;
  end;
  asmtable          =  x86_table;


////////////////////////////////////////////////////////////////////////////////
// I386.opcode.map Conversion
////////////////////////////////////////////////////////////////////////////////
// Format:
//   table, mnemonic flags, dest operand flags, src operand flags,
//   aux operand flags, minimim CPU model [unused],
//   mnemonic text, dest operand text, src operand text,
//   aux operand text
//
//   NOTE: do not trash the INS_* or the OP_[RWX] flags: they are important!
const
  tbl_Main:         Array [0..255] of instr =
  ((table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 0 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 0 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 1 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 1; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 2 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 2 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 3 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 3 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BCDCONV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'daa'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BCDCONV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'das'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BCDCONV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'aaa'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_E or OPTYPE_b or OP_R; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_G or OPTYPE_b or OP_R; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_G or OPTYPE_v or OP_R; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: OP_REG or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: OP_REG or OP_R; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BCDCONV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'aas'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 1 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 3 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 4 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 5 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 6 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_INC; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 7 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 1 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 3 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 4 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 5 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 6 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 7 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 1 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 3 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 4 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 5 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 6 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 7 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 1 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 3 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 4 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 5 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 6 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 7 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSHREGS; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pushad'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POPREGS; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'popad'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BOUNDS; destFlg: ADDRMETH_G or OPTYPE_v or OP_R; srcFlg: ADDRMETH_M or OPTYPE_a or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'bound'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_R; srcFlg: ADDRMETH_G or OPTYPE_w or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'arpl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: ADDRMETH_I or OPTYPE_v or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: ADDRMETH_G or OPTYPE_v or OP_R; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ADDRMETH_I or OP_SIGNED or OP_R; cpu: cpu_80386; mnemonic: 'imul'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: ADDRMETH_I or OPTYPE_b or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: ADDRMETH_G or OPTYPE_v or OP_R; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ADDRMETH_I or  OP_SIGNED or OP_R; cpu: cpu_80386; mnemonic: 'imul'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_IN; destFlg: ADDRMETH_Y or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'insb'; dest: 0; src: 2 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_IN; destFlg: ADDRMETH_Y or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'insd'; dest: 0; src: 2 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_OUT; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_X or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'outsb'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OUT; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_X or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'outsb'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jo'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jno'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jnc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jnz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jbe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ja'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'js'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jns'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jpe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jpo'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jge'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jle'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jg'; dest: 0; src: 0; aux: 0),
   (table: 2; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_b; srcFlg: ADDRMETH_I or OPTYPE_b; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 3; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_v; srcFlg: ADDRMETH_I or OPTYPE_v; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 4; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_v; srcFlg: ADDRMETH_I or OPTYPE_b; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 5; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_v; srcFlg: ADDRMETH_I or OPTYPE_b; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TEST; destFlg: ADDRMETH_E or OPTYPE_b or OP_R; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_b or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_E or OPTYPE_w or OP_W; srcFlg: ADDRMETH_S or OPTYPE_w or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_M or OPTYPE_m or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lea'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_S or OPTYPE_w or OP_W; srcFlg: ADDRMETH_E or OPTYPE_w or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_NOP; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'nop'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0 + REG_DWORD_OFFSET; src: 1 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0 + REG_DWORD_OFFSET; src: 2 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0 + REG_DWORD_OFFSET; src: 3 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0 + REG_DWORD_OFFSET; src: 4 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0 + REG_DWORD_OFFSET; src: 5 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0 + REG_DWORD_OFFSET; src: 6 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_W; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xchg'; dest: 0 + REG_DWORD_OFFSET; src: 7 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SZCONV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cwde'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SZCONV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cdq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CALL; destFlg: ADDRMETH_A or OPTYPE_p or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'callf'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'wait'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSHFLAGS; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pushfd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POPFLAGS; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'popfd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sahf'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lahf'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_O or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_O or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_O or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_O or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_STRMOV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'movsb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRMOV; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'movsd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRCMP; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmpsb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRCMP; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmpsd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TEST; destFlg: OP_REG or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TEST; destFlg: OP_REG or OP_R; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRSTOR; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'stosb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRSTOR; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'stosd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRLOAD; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lodsb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRLOAD; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lodsd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRCMP; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'scasb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_STRCMP; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'scasd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 1 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 2 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 3 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 4 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 5 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 6 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 7 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 1 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 3 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 4 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 5 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 6 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 7 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 6; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_b; srcFlg: ADDRMETH_I or OPTYPE_b; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 7; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_v; srcFlg: ADDRMETH_I or OPTYPE_b; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_RET; destFlg: ADDRMETH_I or OPTYPE_w or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ret'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_RET; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ret'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_M or OPTYPE_p or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'les'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_M or OPTYPE_p or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lds'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ENTER; destFlg: ADDRMETH_I or OPTYPE_w or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'enter'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_LEAVE; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'leave'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_RET; destFlg: ADDRMETH_I or OPTYPE_w or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'retf'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_RET; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'retf'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEBUG; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'int3'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TRAP; destFlg: ADDRMETH_I or OPTYPE_b or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'int'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OFLOW; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'into'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TRET; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'iret'; dest: 0; src: 0; aux: 0),
   (table: 8; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_b; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 1; aux: 0),
   (table: 9; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_v; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 1; aux: 0),
   (table: 10; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_b; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: REG_BYTE_OFFSET + 1; aux: 0),
   (table: 11; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_v; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: REG_BYTE_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_BCDCONV; destFlg: ADDRMETH_I or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'aam'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BCDCONV; destFlg: ADDRMETH_I or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'aad'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XLAT; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xlat'; dest: 0; src: 0; aux: 0),
   (table: 26; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 28; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 30; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 32; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 34; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 36; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 38; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 40; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'loopnz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'loopz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCH; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'loop'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jcxz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_IN; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'in'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_IN; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'in'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OUT; destFlg: ADDRMETH_I or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'out'; dest: 0; src: 0 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_OUT; destFlg: ADDRMETH_I or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'out'; dest: 0; src: 0 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_CALL; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'call'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCH; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCH; destFlg: ADDRMETH_A or OPTYPE_p or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCH; destFlg: ADDRMETH_J or OPTYPE_b or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_IN; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'in'; dest: 0 + REG_BYTE_OFFSET; src: 2 + REG_WORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_IN; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'in'; dest: 0 + REG_DWORD_OFFSET; src: 2 + REG_WORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_OUT; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'out'; dest: 2 + REG_WORD_OFFSET; src: 0 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_OUT; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'out'; dest: 2 + REG_WORD_OFFSET; src: 0 + REG_DWORD_OFFSET; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lock:'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'repne:'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INSTR_PREFIX; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rep:'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_HALT; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'hlt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TOGCF; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmc'; dest: 0; src: 0; aux: 0),
   (table: 12; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_b; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 13; mnemFlg: 0; destFlg: ADDRMETH_E or OPTYPE_v; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CLEARCF; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'clc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SETCF; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'stc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cli'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sti'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CLEARDF; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SETDF; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'std'; dest: 0; src: 0; aux: 0),
   (table: 14; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 15; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_0F:           Array [0..255] of instr =
  ((table: 16; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 17; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_w or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lar'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_w or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lsl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'clts'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'invd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'wbinvd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ud2'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movups'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_W or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_V or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movups'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_W or OPTYPE_q or OP_W; srcFlg: ADDRMETH_V or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movlps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_V or OPTYPE_q or OP_W; srcFlg: ADDRMETH_W or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movlps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'unpcklps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'unpckhps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_q or OP_W; srcFlg: ADDRMETH_W or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movhps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_W or OPTYPE_q or OP_W; srcFlg: ADDRMETH_V or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movhps'; dest: 0; src: 0; aux: 0),
   (table: 19; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_R or OPTYPE_d or OP_W; srcFlg: ADDRMETH_C or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_R or OPTYPE_d or OP_W; srcFlg: ADDRMETH_D or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_C or OPTYPE_d or OP_W; srcFlg: ADDRMETH_R or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_D or OPTYPE_d or OP_W; srcFlg: ADDRMETH_R or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_I or OP_W; srcFlg: ADDRMETH_I or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386 or cpu_80486; mnemonic: 'mov'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movaps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_W or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_V or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movaps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_ps or OP_R; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'cvtpi2ps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_W or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_V or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movntps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_Q or OPTYPE_q or OP_R; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'cvttps2pi'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_Q or OPTYPE_q or OP_R; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'cvtps2pi'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_ss or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ss or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'ucomiss'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ss or OP_W; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'comiss'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM; mnemonic: 'wrmsr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM; mnemonic: 'rdtsc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM; mnemonic: 'rdmsr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'rdpmc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'sysenter'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'sysexit'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovo'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovno'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovnc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovnz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovbe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmova'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovs'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovns'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovpe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovpo'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovge'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovle'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTPRO; mnemonic: 'cmovg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_E or OPTYPE_d or OP_W; srcFlg: ADDRMETH_V or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movmskps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ARITH; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'sqrtps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ARITH; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'rsqrtps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'rcpps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'andps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'andnps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'orps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'xorps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'addps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: ADDRMETH_V or OPTYPE_ps or OP_R; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'mulps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'subps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ARITH; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'minps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DIV; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'divps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ARITH; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'maxps'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'punpcklbw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'punpcklwd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'punpckldq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'packsswb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pcmpgtb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pcmpgtw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pcmpgtd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'packuswb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'punpckhbw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'punpckhwd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'punpckhdq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'packssdw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_P or OPTYPE_d or OP_W; srcFlg: ADDRMETH_E or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'movd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'movq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ADDRMETH_I or  OPTYPE_b or OP_R; cpu: cpu_PENTIUM2; mnemonic: 'pshuf'; dest: 0; src: 0; aux: 0),
   (table: 19; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 20; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 21; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pcmpeqb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pcmpeqw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pcmpeqd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'emms'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_E or OPTYPE_d or OP_W; srcFlg: ADDRMETH_P or OPTYPE_d or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'movd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_Q or OPTYPE_q or OP_W; srcFlg: ADDRMETH_P or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'movq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jo'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jno'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jnc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jnz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jbe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ja'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'js'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jns'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jpe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jpo'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jge'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jle'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCHCC; destFlg: ADDRMETH_J or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'seto'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setno'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setnc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setnz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setbe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'seta'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sets'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setns'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setpe'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setpo'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setge'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setle'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOVCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'setg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 4 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 4 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CPUID; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'cpuid'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'bt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ADDRMETH_I or OPTYPE_b or OP_R; cpu: cpu_80386; mnemonic: 'shld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ADDRMETH_I or OP_R or OP_REG; cpu: cpu_80386; mnemonic: 'shld'; dest: 0; src: 0; aux: 1 + REG_BYTE_OFFSET),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: OP_REG or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 5 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_POP; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'pop'; dest: 5 + REG_SEG_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rsm'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'bts'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ADDRMETH_I or OPTYPE_b or OP_R; cpu: cpu_80386; mnemonic: 'shrd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ADDRMETH_I or OP_R or OP_REG; cpu: cpu_80386; mnemonic: 'shrd'; dest: 0; src: 0; aux: 1 + REG_BYTE_OFFSET),
   (table: 22; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: ADDRMETH_G or OPTYPE_v or OP_R; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'imul'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHGCC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_W; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'cmpxchg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHGCC; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_G or OPTYPE_v or OP_W; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'cmpxchg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_M or OPTYPE_p or OP_W; srcFlg: ADDRMETH_I or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lss'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'btr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_M or OPTYPE_p or OP_W; srcFlg: ADDRMETH_I or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lfs'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_M or OPTYPE_p or OP_W; srcFlg: ADDRMETH_I or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lgs'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'movzx'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_w or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'movzx'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ud1'; dest: 0; src: 0; aux: 0),
   (table: 23; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_G or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'btc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_G or OPTYPE_v or OP_R; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'bsf'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_G or OPTYPE_v or OP_R; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'bsr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'movsx'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_G or OPTYPE_v or OP_W; srcFlg: ADDRMETH_E or OPTYPE_w or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'movsx'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_G or OPTYPE_b or OP_W; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'xadd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'xadd'; dest: 0; src: 0; aux: 0),
   (table: 24; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_E or OPTYPE_d or OP_R; auxFlg: ADDRMETH_I or OPTYPE_b or OP_R; cpu: cpu_PENTIUM2; mnemonic: 'pinsrw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_G or OPTYPE_d or OP_W; srcFlg: ADDRMETH_P or OPTYPE_q or OP_R; auxFlg: ADDRMETH_I or OPTYPE_b or OP_R; cpu: cpu_PENTIUM2; mnemonic: 'pextrw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_V or OPTYPE_ps or OP_W; srcFlg: ADDRMETH_W or OPTYPE_ps or OP_R; auxFlg: ADDRMETH_I or OPTYPE_b or OP_R; cpu: cpu_PENTIUM2; mnemonic: 'shufps'; dest: 0; src: 0; aux: 0),
   (table: 25; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 1 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 2 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 3 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 4 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 5 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 6 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XCHG; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'bswap'; dest: 7 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrlw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrlq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pmullw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_G or OPTYPE_d or OP_W; srcFlg: ADDRMETH_P or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pmovmskb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psubusb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psubusw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pminub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pand'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'paddusb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'paddusw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ARITH; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pmaxub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pandn'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pavgb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psraw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrad'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pavgw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pmulhuw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pmulhw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_W or OPTYPE_q or OP_W; srcFlg: ADDRMETH_V or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'movntq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psubsb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psubsw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ARITH; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pminsw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'por'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'paddsb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'paddsw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ARITH; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'pmaxsw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pxor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psllw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pslld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psllq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pmaddwd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'psadbw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MOV; destFlg: ADDRMETH_P or OPTYPE_pi or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_pi or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'maskmovq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psubb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psubw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psubd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'paddb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'paddw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_Q or OPTYPE_q or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'paddd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_0F00:         Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sldt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'str'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lldt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ltr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'verr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'verw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_0F01:         Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_M or OPTYPE_s or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sgdt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_M or OPTYPE_s or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sidt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_M or OPTYPE_s or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lgdt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_M or OPTYPE_s or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lidt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'smsw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_E or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'lmsw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: ADDRMETH_M or OPTYPE_b or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80486; mnemonic: 'invlpg'; dest: 0; src: 0; aux: 0));

const
  tbl_0F18:         Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_SYSTEM; destFlg: OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'prefetch'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'prefetch'; dest: 0 + REG_TEST_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'prefetch'; dest: 1 + REG_TEST_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SYSTEM; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'prefetch'; dest: 2 + REG_TEST_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_0F71:         Array [0..7] of instr =
  ((table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrlw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psraw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psllw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_0F72:         Array [0..7] of instr =
  ((table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrad'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'pslld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_0F73:         Array [0..1] of instr =
  ((table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psrlq'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OTHER; destFlg: ADDRMETH_P or OPTYPE_q or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'psllq'; dest: 0; src: 0; aux: 0));

const
  tbl_0FAE:         Array [0..4] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'fxsave'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTMMX; mnemonic: 'fxrstor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'ldmxcsr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'stmxcsr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM2; mnemonic: 'sfence'; dest: 0; src: 0; aux: 0));

const
  tbl_0FBA:         Array [0..3] of instr =
  ((table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'bt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'bts'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'btr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BITTEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'btc'; dest: 0; src: 0; aux: 0));

const
  tbl_0FC7:         Array [0..0] of instr =
  ((table: 0; mnemFlg: INS_XCHGCC; destFlg: ADDRMETH_M or OPTYPE_q or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_PENTIUM; mnemonic: 'cmpxch8b'; dest: 0; src: 0; aux: 0));

const
  tbl_80:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_E or OPTYPE_b or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0));

const
  tbl_81:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0));

const
  tbl_82:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0));

const
  tbl_83:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'add'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_OR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'or'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ADD; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'adc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sbb'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_AND; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'and'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SUB; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_XOR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'xor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CMP; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'cmp'; dest: 0; src: 0; aux: 0));

const
  tbl_C0:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rol'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ror'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sal'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sar'; dest: 0; src: 0; aux: 0));

const
  tbl_C1:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rol'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ror'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shl'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sal'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sar'; dest: 0; src: 0; aux: 0));

const
  tbl_D0:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rol'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM  or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ror'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM  or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcl'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM  or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcr'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM  or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shl'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM  or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shr'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM  or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sal'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ADDRMETH_I or OP_IMM  or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sar'; dest: 0; src: 1; aux: 0));

const
  tbl_D1:        Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rol'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ror'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcl'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcr'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shl'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shr'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sal'; dest: 0; src: 1; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ADDRMETH_I or OP_IMM or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sar'; dest: 0; src: 1; aux: 0));

const
  tbl_D2:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rol'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ror'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcl'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcr'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shl'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shr'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sal'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sar'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0));

const
  tbl_D3:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rol'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'ror'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_ROL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcl'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_ROR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'rcr'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shl'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'shr'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHL; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sal'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0),
   (table: 0; mnemFlg: INS_SHR; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'sar'; dest: 0; src: 1 + REG_BYTE_OFFSET; aux: 0));

const
  tbl_F6:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_TEST; destFlg: ADDRMETH_E or OPTYPE_b or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TEST; destFlg: ADDRMETH_E or OPTYPE_b or OP_R; srcFlg: ADDRMETH_I or OPTYPE_b or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_NOT; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'not'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_NEG; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'neg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mul'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'imul'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DIV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'div'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DIV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_b or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'idiv'; dest: 0 + REG_BYTE_OFFSET; src: 0; aux: 0));

const
  tbl_F7:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_TEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_TEST; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ADDRMETH_I or OPTYPE_v or OP_SIGNED or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'test'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_NOT; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'not'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_NEG; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'neg'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'mul'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_MUL; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'imul'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DIV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'div'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DIV; destFlg: OP_REG or OP_W; srcFlg: ADDRMETH_E or OPTYPE_v or OP_R; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'idiv'; dest: 0 + REG_DWORD_OFFSET; src: 0; aux: 0));

const
  tbl_FE:           Array [0..1] of instr =
  ((table: 0; mnemFlg: INS_INC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: ADDRMETH_E or OPTYPE_b or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 0; src: 0; aux: 0));

const
  tbl_FF:           Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_INC; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'inc'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_DEC; destFlg: ADDRMETH_E or OPTYPE_v or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'dec'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CALL; destFlg: ADDRMETH_E or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'call'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_CALL; destFlg: ADDRMETH_E or OPTYPE_p or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'call'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCH; destFlg: ADDRMETH_E or OPTYPE_v or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_BRANCH; destFlg: ADDRMETH_E or OPTYPE_p or OP_X; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'jmp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_PUSH; destFlg: ADDRMETH_E or OPTYPE_v or OP_R; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80386; mnemonic: 'push'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: 0; mnemonic: #0; dest: 0; src: 0; aux: 0));

// Note : fix < 8 tables based on previous op.map
// FPU Opcode Tables: Note that these are split into two tables per ESC byte
// [0xD#] based on whether the subsequent modR/M byte is in the range 0x00-0xBF or not

const
  tbl_fpuD8_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuD8_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0));

const
  tbl_fpuD9_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fs or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fv or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fldenv'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fldcw'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fv or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstenv'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstcw'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuD9_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxch'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fnop'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fchs'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fabs'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ftst'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxam'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld1'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld2t'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld2t'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fldpi'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fldlg2'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fldln2'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fldz'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'f2xm1'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fyl2x'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fptan'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fpatan'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fxtract'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fprem1'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdecstp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fincstp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fprem'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fyl2xp1'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsqrt'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsincos'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'frndint'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fscale'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsin'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcos'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDA_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fiadd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fimul'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ficom'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ficomp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fisub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fisubr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fidiv'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fidivr'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDA_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmove'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucompp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDB_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fild'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fist'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_d or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fistp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fe or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fe or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDB_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnb'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovne'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnbe'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcmovnu'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fclex'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'finit'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomi'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDC_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcom'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDC_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fadd'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmul'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubr'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsub'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivr'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdiv'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0));

const
  tbl_fpuDD_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fd or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fv or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'frstor'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fv or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsave'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstsw'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDD_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 1; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 2; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 3; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 4; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 5; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 6; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ffree'; dest: REG_FPU_OFFSET + 7; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 1; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 2; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 3; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 4; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 5; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 6; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fst'; dest: REG_FPU_OFFSET + 7; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 1; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 2; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 3; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 4; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 5; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 6; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstp'; dest: REG_FPU_OFFSET + 7; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucom'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 1; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 2; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 3; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 4; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 5; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 6; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomp'; dest: REG_FPU_OFFSET + 7; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDE_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fiadd'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fimul'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ficom'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'ficomp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fisub'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fisubr'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fidiv'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fidivr'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDE_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'faddp'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fmulp'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcompp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubrp'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fsubp'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivrp'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 1; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 2; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 3; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 4; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 5; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 6; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fdivp'; dest: REG_FPU_OFFSET + 7; src: REG_FPU_OFFSET + 0; aux: 0));

const
  tbl_fpuDF_00BF:   Array [0..7] of instr =
  ((table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fild'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fist'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_w or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fistp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fb or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fbld'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_q or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fild'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_fb or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fbstp'; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: ADDRMETH_M or OPTYPE_q or OP_W; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fistp'; dest: 0; src: 0; aux: 0));

const
  tbl_fpuDF_rest:   Array [0..63] of instr =
  ((table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fstsw'; dest: REG_WORD_OFFSET + 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fucomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 0; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 1; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 2; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 3; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 4; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 5; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 6; aux: 0),
   (table: 0; mnemFlg: INS_FPU; destFlg: OP_REG or OP_W; srcFlg: OP_REG or OP_R; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: 'fcomip'; dest: REG_FPU_OFFSET + 0; src: REG_FPU_OFFSET + 7; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0),
   (table: 0; mnemFlg: 0; destFlg: ARG_NONE; srcFlg: ARG_NONE; auxFlg: ARG_NONE; cpu: cpu_80387; mnemonic: #0; dest: 0; src: 0; aux: 0));

implementation

end.
