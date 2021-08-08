#include <Uefi.h>


UINTN get_memory_map(EFI_SYSTEM_TABLE* st, EFI_MEMORY_DESCRIPTOR* mem_map_ptr)
{

    EFI_STATUS result;
    UINTN mem_map_size = 0;
    UINTN map_key;
    UINTN descriptor_size;
    UINT32 descriptor_version = 1;

    // get the memory map size
    result = st->BootServices->GetMemoryMap(
        &mem_map_size,
        mem_map_ptr,
        NULL,
        &descriptor_size,
        NULL
    );

    // keep trying to allocate and free until GetMemoryMap() succeeds
    // call ExitBootSerivces() immediately after this loop ends
    EFI_STATUS GetMemoryMap_result;
    do
    {
        // increase mem_map_size because allocating might increases memory map size
        mem_map_ptr->PhysicalStart = 0;
        mem_map_size = mem_map_size + 2 * descriptor_size;
        void *buffer;

        // allocate a pool for the memory map
        result = st->BootServices->AllocatePool(
            EfiLoaderCode,
            mem_map_size,
            &buffer
        );

        // get memory map
        GetMemoryMap_result = st->BootServices->GetMemoryMap(
            &mem_map_size,
            mem_map_ptr,
            &map_key,
            &descriptor_size,
            &descriptor_version
        );

        // if GetMemoryMap() failed, free pool and try again
        if (GetMemoryMap_result != EFI_SUCCESS){
            result = st->BootServices->FreePool(&buffer);
        }
    }
    while (GetMemoryMap_result != EFI_SUCCESS);

    return map_key;
}

EFI_STATUS EFIAPI uefi_main(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE  *SystemTable)
{
    EFI_STATUS result;
    EFI_MEMORY_DESCRIPTOR* mem_map_ptr;
    UINTN map_key;
    map_key = get_memory_map(SystemTable, mem_map_ptr);

    // exit efi
    result = SystemTable->BootServices->ExitBootServices(ImageHandle, map_key);

    return result;
}