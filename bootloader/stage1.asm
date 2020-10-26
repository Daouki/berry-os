org     0x7C00
bits    16


;; Creates a definition for a partition entry with the given index. Those entries
;; are meant to be filled by a disk structure generator / partition manager
;; software like Parted.
%macro make_partition_entry 1
partition_entry_%1:
.status                 db      0
.first_sector_chs       db      0, 0, 0
.type                   db      0
.last_sector_chs        db      0, 0, 0
.first_sector_lba       dd      0
.sector_count           dd      0
%endmacro


partition_table_offset  equ     446
partition_table_size    equ     4 * partition_entry_size
partition_entry_size    equ     16


;; Sets the execution environment for the bootsector code.
_entry:
        mov     ax, 0
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax

        cld
        sti

        ; Set the stack pointer to memory area we're not going to use.
        mov     sp, 0x7C00

        ; Some BIOSes may set the CS:IP register pair to something else than
        ; we expect, that is 0x0000:0x7C00. Make a far jump to ensure expected
        ; register values.
        jmp     0x0000:_start


_start:
        ; Clear the screen by setting the 80x25 text mode.
        mov     ah, 0x00
        mov     al, 0x03
        int     0x10

        ; Load the bootloader into the memory at 0x7C00.
        mov     ah, 0x42        ; Function: EXTENDED READ.
        mov     si, bootloader_disk_address_packet
        int     0x13            ; Load the bootloader.

        call    enable_a20

        ;; Disable both Interrupt Flag and Non-Maskable Interrupts.
        cli
        in      al, 0x70
        or      al, 0x80
        out     0x70, al

        lgdt    [global_descriptor_table_pointer]

        ; Enable the Protection Enabled bit in CR0.
        mov     eax, cr0
        or      eax, 1
        mov     cr0, eax

        ; Enable the Protected Mode by doing a far jump.
        jmp     0x0008:enter_protected_mode


;; Enables the A20 line.
;; Because we assume a modern x86_64 machine, we don't expect this process
;; to fail. In truth, it's pretty much likely, that the A20 is already enabled.
enable_a20:
        call    is_a20_enabled
        jc      .enable_using_bios
        ret

.enable_using_bios:
        mov     ax, 0x2401
        int     0x15
        call    is_a20_enabled
        ret

.enable_using_keyboard_controller:
        call    wait_for_keyboard_input_ready
        mov     al, 0xAD
        out     0x64, al

        call    wait_for_keyboard_output_ready
        in      al, 0x60
        push    ax

        call    wait_for_keyboard_input_ready
        mov     al, 0xD1
        out     0x64, al

        call    wait_for_keyboard_input_ready
        pop     ax
        or      al, 1 << 1
        out     0x60, al

        call    wait_for_keyboard_input_ready
        
        call    is_a20_enabled
        jc      .enable_using_fast_gate
        ret

.enable_using_fast_gate:
        in      al, 0x92
        or      al, 1 << 1
        out     0x92, al

        call    is_a20_enabled
        ret

        ; TODO: Can we fit more enable methods in here? At least Fast Gate
        ; method, who cares about keyboard controller :^)


;; Checks whether the A20 line is enabled.
;; Carry Flag clear if enabled; set if disabled.
is_a20_enabled:
        push    ax
        push    ds

        mov     ax, 0xFFFF
        mov     ds, ax
        mov     byte [ds:0x0510], 0xFF

        xor     ax, ax
        mov     ds, ax
        cmp     byte [ds:0x0500], 0xFF
        
        clc
        jne     .exit
        stc

.exit:
        pop     ds
        pop     ax
        ret


;; Waits until the keyboard controller is ready to take commands.
wait_for_keyboard_input_ready:
        push    ax
        in      al, 0x64
        test    al, 1 << 1
        jnz     wait_for_keyboard_input_ready
        pop    ax
        ret


;; Waits until the output buffer of the keyboard controller is ready.
wait_for_keyboard_output_ready:
        push    ax
        in      al, 0x64
        test    al, 1
        jnz     wait_for_keyboard_output_ready
        pop    ax
        ret


bits    32
enter_protected_mode:
        ; Print something to the screen.
        mov     eax, 0x09650942
        mov     [0xB8000], eax
        mov     eax, 0x09720972
        mov     [0xB8004], eax
        mov     eax, 0x0F4F0979
        mov     [0xB8008], eax
        mov     eax, 0x00000F53
        mov     [0xB800C], eax

        ; Temporary stop point, so we can make sure that things aren't broke.
        ;hlt
        ;jmp     $

        ; Jump to the loaded bootloader.
        jmp     0x7E00


;; Simplistic global descriptor table that's only used to get the CPU into
;; the Protected Mode.
global_descriptor_table_pointer:
.size           dw      global_descriptor_table.end - global_descriptor_table - 1
.pointer        dd      global_descriptor_table

global_descriptor_table:
.null_segment   dq      0x0000000000000000
.protected_code dq      0x00CF9A000000FFFF
.protected_data dq      0x00CF92000000FFFF
.end:


;; Disk address packet for the bootloader. Used by Int 0x13 with AH = 0x42.
;; See: http://www.ctyme.com/intr/rb-0708.htm
bootloader_disk_address_packet:
.packet_size    db      0x10
.padding        db      0x00
.sector_count   dw      63      ; Number of sectors inside of the MBR gap.
.target_offset  dw      0x7E00
.target_segment dw      0x0000
.start_block    dq      0x01


;; Describes the locations, sizes, and other attributes of partitions.
times   partition_table_offset - ($ - $$)       db      0
partition_table:
make_partition_entry    1
make_partition_entry    2
make_partition_entry    3
make_partition_entry    4
partition_table_end:


%if     partition_table_end - partition_table != partition_table_size
        %error  Invalid partition table size
%endif


bootable_signature      db      0x55, 0xAA


%if     $ - $$ != 512
        %error bootsector code is not exactly 512 bytes long
%endif
