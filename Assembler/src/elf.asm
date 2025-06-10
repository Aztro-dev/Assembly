%ifndef ELF_ASM
%define ELF_ASM
; ---------- Elf Header (Ehdr) ----------

; --- e_ident ---
%define ELFMAG0 0x7f
%define ELFMAG1 'E'
%define ELFMAG2 'L'
%define ELFMAG3 'F'
%ifndef EI_CLASS
%define EI_CLASS
  ; Invalid class
  %define ELFCLASSNONE  0
  ; 32-bit arch
  %define ELFCLASS32    1
  ; 64-bit arch
  %define ELFCLASS64    2
%endif
%ifndef EI_DATA
%define EI_DATA
  ; Unknown data format 
  %define ELFDATANONE   0
  ; Two's complement, little endian
  %define ELFDATA2LSB   1
  ; Two's complement, big endian
  %define ELFDATA2MSB   2
%endif
%ifndef EI_VERSION
%define EI_VERSION
  ; Invalid version
  %define EV_NONE       0
  ; Current version
  %define EV_CURRENT    1
%endif
%ifndef EI_OSABI
; Yes there are more ABIs, no I don't want to implement them
%define EI_OSABI
  ; The same as ELFOSABI_SYSV
  %define ELFOSABI_NONE 0
  ; UNIX System V ABI
  %define ELFOSABI_SYSV 0
  ; Linux ABI
  %define ELFOSABI_LINUX 3
%endif
%define EI_ABIVERSION   0
; 9 bytes are used for actual data, the rest are padding/for future uses
; Defines the size of the e_ident array
%define EI_NIDENT       16

; --- e_type ---
%ifndef E_TYPE
%define E_TYPE
  ; An unknown type
  %define ET_NONE       0
  ; Relocatable file
  %define ET_REL        1
  ; Executable file
  %define ET_EXEC       2
  ; Shared object file
  %define ET_DYN        3
  ; Core file
  %define ET_CORE       4
%endif

; --- e_machine ---
%ifndef E_MACHINE
%define E_MACHINE
  ; An unknown type, RISC-V machines fall into this category
  %define EM_NONE       0
  ; I will not be implementing the rest
%endif

; --- e_version ---
%ifndef E_VERSION
%define E_VERSION
  ; Invalid version
  %define EV_NONE       0
  ; Invalid version
  %define EV_CURRENT    1
%endif

; --- e_phnum ---
%ifndef E_PHNUM
; Holds the number of entries in the program's header table
; This number times e_phentsize is the size of the header table in bytes
%define E_PHNUM
  ; The max number that e_phnum can have
  ; If the actual number is bigger than PN_XNUM, then the real number of entries
  ; Is stored in sh_info for the initial entry in the section header table, otherwise sh_info is 0
  %define PN_XNUM       0xffff
%endif

; --- e_shnum ---
%ifndef E_SHNUM
; Holds the number of entries in the section's header table
; This number times e_shentsize is the size of the section's header table in bytes
; If there is no section header table, e_shnum would be 0
%define E_SHNUM
  ; The max number that e_shnum can have
  ; If the number of entries in the section's header table is more than SHN_LORESERVE, then 
  ; e_shnum holds 0 and and the real number of entries is stored in the sh_size member of the section header table
  ; Otherwise, sh_size holds 0
  %define SHN_LORESERVE 0xff00
%endif

; --- e_shstrndx
%ifndef E_SHSTRNDX
; Holds the section header table index of the section name string table entry
; If there is no section header table, this value holds SHN_UNDEF
%define E_SHSTRNDX
  %define SHN_UNDEF    0
  ; If the section header table section is greater than or equal to SHN_LORESERVE, then e_shstrndx holds SHN_XINDEX
  ; and the real index is held in the sh_link member of the initial section header table entry.
  ; Otherwise, sh_link holds 0
  %define SHN_XINDEX   0xffff
%endif

; This struct uses "N", but we assume that N is 64 bits for now.
struc ElfN_Ehdr
  .e_ident      resb EI_NIDENT
  .e_type       resw 1 ; uint16_t
  .e_machine    resw 1 ; uint16_t
  .e_version    resd 1 ; uint32_t
  .e_entry      resq 1 ; ElfN_Addr
  .e_phoff      resq 1 ; ElfN_Off
  .e_shoff      resq 1 ; ElfN_Off
  .e_flags      resd 1 ; uint32_t
  .e_ehsize     resw 1 ; uint16_t
  .e_phentsize  resw 1 ; uint16_t
  .e_phnum      resw 1 ; uint16_t
  .e_shentsize  resw 1 ; uint16_t
  .e_shnum      resw 1 ; uint16_t
  .e_shstrndx   resw 1 ; uint16_t
endstruc

; ---------- Program Header (Phdr) ----------
; An executable or shared object file's program header table is an
; array of structures, each describing a segment or other
; information the system needs to prepare the program for execution.
; An object file segment contains one or more sections. 
; Program headers are meaningful only for executable and shared object
; files.  A file specifies its own program header size with the ELF
; header's e_phentsize and e_phnum members.

; This struct uses "N", but we assume that N is 64 bits for now.
struc ElfN_Phdr
  .p_type   resd 1 ; uint32_t
  .p_flags  resd 1 ; uint32_t
  .p_offset resq 1 ; Elf64_Off
  .p_vaddr  resq 1 ; Elf64_Addr
  .p_paddr  resq 1 ; Elf64_Addr
  .p_filesz resq 1 ; uint64_t
  .p_memsz  resq 1 ; uint64_t
  .p_align  resq 1 ; uint64_t
endstruc

%endif

; TODO: How to find e_entry (_start location)
; https://stackoverflow.com/a/71367851/16159716
