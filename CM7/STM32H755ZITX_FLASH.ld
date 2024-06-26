/*
******************************************************************************
**
**  File        : LinkerScript.ld
**
**  Author      : STM32CubeIDE
**
**  Abstract    : Linker script for STM32H7 series
**                      1024Kbytes FLASH
**                      800Kbytes RAM
**
**                Set heap size, stack size and stack location according
**                to application requirements.
**
**                Set memory bank area and size if external memory is used.
**
**  Target      : STMicroelectronics STM32
**
**  Distribution: The file is distributed as is without any warranty
**                of any kind.
**
*****************************************************************************
** @attention
**
** Copyright (c) 2024 STMicroelectronics.
** All rights reserved.
**
** This software is licensed under terms that can be found in the LICENSE file
** in the root directory of this software component.
** If no LICENSE file comes with this software, it is provided AS-IS.
**
*****************************************************************************
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = ORIGIN(SRAM_AXI_D1) + LENGTH(SRAM_AXI_D1); /* end of "RAM_D1" Ram type memory */

_Min_Heap_Size = 0x200; /* required amount of heap  */
_Min_Stack_Size = 0x400; /* required amount of stack */

/* Memories definition */
MEMORY
{
  ITCMRAM		(xrw)  : ORIGIN = 0x00000000, LENGTH = 64K
  FLASH			(rx)   : ORIGIN = 0x08000000, LENGTH = 1024K    /* Memory is divided. Actual start is 0x08000000 and actual length is 2048K */
  DTCMRAM		(xrw)  : ORIGIN = 0x20000000, LENGTH = 128K		/* DTCM D1: zmienne krytyczne, rozmiar=0x20000 */
  SRAM_AXI_D1	(xrw)  : ORIGIN = 0x24000000, LENGTH = 512K  	/* AXI-SRAM D1: dane i bufory, stos, sterta, rozmiar=0x80000 */
  SRAM_AHB1_D2	(xrw)  : ORIGIN = 0x30000000, LENGTH = 128K  	/* AHB-SRAM D2: bufory DMA, kod dla M4 */
  SRAM_AHB2_D2 	(xrw)  : ORIGIN = 0x30020000, LENGTH = 128K		/* AHB-SRAM D2: bufory DMA, dane dla M4 */
  SRAM_AHB3_D2	(xrw)  : ORIGIN = 0x30040000, LENGTH = 32K		/* AHB-SRAM D2: bufory ethernet, USB, współdzielenie danych*/
  SRAM_AHB4_D3	(xrw)  : ORIGIN = 0x38000000, LENGTH = 64K		/* AHB-SRAM D3: backup w czasie stabdby, współdzielenie danych między rdzeniami, rozmiar=0x10000 */
  BACKUP  (rw)   : ORIGIN = 0x38800000, LENGTH = 4K
}

/* Sections */
SECTIONS
{
  /* The startup code into "FLASH" Rom type memory */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH

  /* The program code and other data into "FLASH" Rom type memory */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >FLASH

  /* Constant data into "FLASH" Rom type memory */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >FLASH

  .ARM.extab (READONLY) : /* The READONLY keyword is only supported in GCC11 and later, remove it if using GCC10 or earlier. */
  {
    . = ALIGN(4);
    *(.ARM.extab* .gnu.linkonce.armextab.*)
    . = ALIGN(4);
  } >FLASH
  .ARM (READONLY) : /* The READONLY keyword is only supported in GCC11 and later, remove it if using GCC10 or earlier. */
  {
    . = ALIGN(4);
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
    . = ALIGN(4);
  } >FLASH

  .preinit_array (READONLY) : /* The READONLY keyword is only supported in GCC11 and later, remove it if using GCC10 or earlier. */
  {
    . = ALIGN(4);
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
    . = ALIGN(4);
  } >FLASH

  .init_array (READONLY) : /* The READONLY keyword is only supported in GCC11 and later, remove it if using GCC10 or earlier. */
  {
    . = ALIGN(4);
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
    . = ALIGN(4);
  } >FLASH

  .fini_array (READONLY) : /* The READONLY keyword is only supported in GCC11 and later, remove it if using GCC10 or earlier. */
  {
    . = ALIGN(4);
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
    . = ALIGN(4);
  } >FLASH

  /* Used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections into "RAM" Ram type memory */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */
    *(.RamFunc)        /* .RamFunc sections */
    *(.RamFunc*)       /* .RamFunc* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >SRAM_AXI_D1 AT> FLASH

  /* Uninitialized data section into "RAM" Ram type memory */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss section */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >SRAM_AXI_D1

  /* User_heap_stack section, used to check that there is enough "RAM" Ram  type memory left */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >SRAM_AXI_D1

/* Sekcja zmiennych krytycznych w pamięci DTCM 128K*/
.zmienneDTCM (NOLOAD) :
  {
    *(.Zmienne_DTCM)  
  } >DTCMRAM

/* Sekcja buforów w pamięci z dostępem do magistrali AXI 512K*/
.bufory_AXI (NOLOAD) :
  {
    *(.BuforyObrazu_AXI)  
  } >SRAM_AXI_D1

/* Sekcja buforów w pamięci SRAM_AHB1_D2 128K*/
.bufory_AHB1_D2 (NOLOAD) :
  {
    *(.Bufory_D1)  
  } >SRAM_AHB1_D2

/* Sekcja buforów w pamięci SRAM_AHB2_D2 128K*/
.bufory_AHB2_D2 (NOLOAD) :
  {
    *(.Bufory_D2)  
  } >SRAM_AHB2_D2
  
/* Sekcja buforów ethernetu SRAM_AHB3_D2 32kB */
.bufory_AHB3_D2 (NOLOAD) :
  {
    . = ABSOLUTE(0x30040000);
    *(.RxDecripSection) 
    
    . = ABSOLUTE(0x30040100);
    *(.TxDecripSection)
    
    . = ABSOLUTE(0x30040200);
    *(.Rx_PoolSection)  
  } >SRAM_AHB3_D2

/* Sekcja buforów w pamięci SRAM_D4 aktywnych również w standby, 64k*/
.bufory_AHB4_D2 (NOLOAD) :
  {
    *(.Bufory_D4)  
  } >SRAM_AHB4_D3  
  
 /* Sekcja backup podtrzymywana baterią, 4k*/
.backup (NOLOAD) :
  {
    *(.Backup)  
  } >BACKUP
     
  /* Remove information from the compiler libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
