/* Linker script for Nordic Semiconductor nRF51 devices
 *
 * Version: Sourcery G++ 4.5-1
 * Support: https://support.codesourcery.com/GNUToolchain/
 *
 * Copyright (c) 2007, 2008, 2009, 2010 CodeSourcery, Inc.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions.  No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */
OUTPUT_FORMAT ("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")

/* Linker script to place sections and symbol values. Should be used together
 * with other linker script that defines memory regions FLASH and RAM.
 * It references following symbols, which must be defined in code:
 *   Reset_Handler : Entry of reset handler
 *
 * It defines following symbols, which code can use without definition:
 *   __exidx_start
 *   __exidx_end
 *   __etext
 *   __data_start__
 *   __preinit_array_start
 *   __preinit_array_end
 *   __init_array_start
 *   __init_array_end
 *   __fini_array_start
 *   __fini_array_end
 *   __data_end__
 *   __bss_start__
 *   __bss_end__
 *   __end__
 *   end
 *   __HeapLimit
 *   __StackLimit
 *   __StackTop
 *   __stack
 */
ENTRY(Reset_Handler)

SECTIONS
{
	/* Code region starts here with 1024bytes of interrupt vector table */
	.text : ALIGN(4)
	{
		__application_start_address = .;
		KEEP(*(.isr_vector))
		FILL(0xff)
		. = __application_start_address + 0x200; /* constant offset to keep license at same address */

		/* Start of License Data */
		/* License section MUST be 0xFF filled in flash */
		__license_data_start_address = .;
		KEEP(*(.LicenseCompatibleMagicNumber))
		FILL(0xff)  /* fill unused area to have consistent checksum */

		/*
		* Can be used for debugging, must not be used for production
		* As this area needs to be filled with 0xFF
		* KEEP(*(.License))
		*/

		. = __application_start_address + 0x400; /* constant offset to keep version at same address */

		KEEP(*(.Version))
		KEEP(*(.AppSize))
		KEEP(*(.BootloaderAddress))
		KEEP(*(.AppMagicNumber))
		
		PROVIDE(__start_conn_type_resolvers = .);
		KEEP(*(.ConnTypeResolvers))
		PROVIDE(__stop_conn_type_resolvers = .);

		KEEP(*(.init))
		KEEP(*(.fini))

		/* .ctors */
		*crtbegin.o(.ctors)
		*crtbegin?.o(.ctors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
		*(SORT(.ctors.*))
		KEEP(*(.ctors))

		/* .dtors */
 		*crtbegin.o(.dtors)
 		*crtbegin?.o(.dtors)
 		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
 		*(SORT(.dtors.*))
 		*(.dtors)

		*(.text*)
		*(.rodata .rodata.* .rodata1)
		*(.gnu.linkonce.r.*)
	} > FLASH
	
	  .sdh_soc_observers :
	  {
	    PROVIDE(__start_sdh_soc_observers = .);
	    KEEP(*(SORT(.sdh_soc_observers*)))
	    PROVIDE(__stop_sdh_soc_observers = .);
	  } > FLASH
	  .sdh_ble_observers :
	  {
	    PROVIDE(__start_sdh_ble_observers = .);
	    KEEP(*(SORT(.sdh_ble_observers*)))
	    PROVIDE(__stop_sdh_ble_observers = .);
	  } > FLASH
	
	  .sdh_stack_observers :
	  {
	    PROVIDE(__start_sdh_stack_observers = .);
	    KEEP(*(SORT(.sdh_stack_observers*)))
	    PROVIDE(__stop_sdh_stack_observers = .);
	  } > FLASH
	  .sdh_req_observers :
	  {
	    PROVIDE(__start_sdh_req_observers = .);
	    KEEP(*(SORT(.sdh_req_observers*)))
	    PROVIDE(__stop_sdh_req_observers = .);
	  } > FLASH
	  .sdh_state_observers :
	  {
	    PROVIDE(__start_sdh_state_observers = .);
	    KEEP(*(SORT(.sdh_state_observers*)))
	    PROVIDE(__stop_sdh_state_observers = .);
	  } > FLASH

	.ARM.extab :
	{
		*(.ARM.extab* .gnu.linkonce.armextab.*)
	} > FLASH

	PROVIDE (__exidx_start = .);
	.ARM.exidx :
	{
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
	} > FLASH
	PROVIDE (__exidx_end = .);

	.eh_frame_hdr :
	{
		*(.eh_frame_hdr)
	} > FLASH

	.eh_frame : ONLY_IF_RO
	{
		*(.eh_frame)
	} > FLASH

	.gcc_except_table : ONLY_IF_RO
	{
		*(.gcc_except_table .gcc_except_table.*)
	} > FLASH

	__etext = .;
	.application_ram_start_dummy : ALIGN(4)
   	{
		__application_ram_start_address = .;
   	} > RAM

	.eh_frame ALIGN(4): ONLY_IF_RW
	{
		*(.eh_frame)
	} > RAM

	.gcc_except_table ALIGN(4): ONLY_IF_RW
	{
		*(.gcc_except_table .gcc_except_table.*)
	} > RAM

	.data : ALIGN(4)
	{
		/* preinit data */
		PROVIDE (__preinit_array_start = .);
		KEEP(*(.preinit_array))
		PROVIDE (__preinit_array_end = .);

		. = ALIGN(4);
		/* init data */
		PROVIDE (__init_array_start = .);
		*(SORT(.init_array.*))
		KEEP(*(.init_array))
		PROVIDE (__init_array_end = .);

		. = ALIGN(4);
		/* finit data */
		PROVIDE (__fini_array_start = .);
		*(SORT(.fini_array.*))
		KEEP(*(.fini_array))
		PROVIDE (__fini_array_end = .);

		. = ALIGN(4);

		*(vtable)
		*(.data*)
		*(.fastrun*)

		*(.jcr)

		/* All data end */
		__data_end__ = .;

	} > RAM AT > FLASH

	__data_start__ = ADDR(.data);
	__data_loc__ = LOADADDR(.data);
	__data_size__ = SIZEOF(.data);

   	.application_end_dummy : ALIGN(4)
   	{
		__application_end_address = .;
   	} > FLASH

	.bss : ALIGN(4)
	{
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		*(.gnu.linkonce.b.*)
		__bss_end__ = .;
		PROVIDE(end = .);
	} > RAM

        __bss_size__ = SIZEOF(.bss);
        
    .noinit (NOLOAD): ALIGN(4)
	{
		__noinit_start__ = .;
		*(.noinit .noinit.*)
		__noinit_end__ = .;
	} > RAM_NO_INIT

	.heap : ALIGN(4)
	{
		__end__ = .;
		end = __end__;
		_pvHeapStart = .;
		*(.heap*)
		__HeapLimit = .;
	} > RAM

	/* Not named __StackLimit as that might be used by Nordic. */
	__FruityStackLimit = .;

	/* .stack_dummy section doesn't contains any symbols. It is only
	 * used for linker to calculate size of stack sections, and assign
	 * values to stack symbols later */
	.stack_dummy : ALIGN(4)
	{
		*(.stack*)
	} > RAM

	/* Set stack top to end of RAM, and stack limit move down by
	 * size of stack_dummy section */
	__StackTop = ORIGIN(RAM) + LENGTH(RAM);
	__StackLimit = __StackTop - SIZEOF(.stack_dummy);
	PROVIDE(__stack = __StackTop);

	/* Check if data + heap + stack exceeds RAM limit */
	ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack")
}

