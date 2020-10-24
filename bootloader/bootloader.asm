%include        "bootsector.asm"


sector_size             equ     512
mbr_gap_sectors         equ     63
mbr_total_sectors       equ     mbr_gap_sectors + 1


times   mbr_total_sectors * sector_size - ($ - $$)        db      0


%if     $ - $$ != mbr_total_sectors * sector_size
        %error bootloader code is not exactly 32 kibibytes long
%endif
