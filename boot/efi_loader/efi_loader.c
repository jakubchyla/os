#include <Uefi.h>


EFI_STATUS EFIAPI UefiMain (IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE  *SystemTable)
{
    EFI_STATUS result;
    UINTN mem_map_size = 0;
    EFI_MEMORY_DESCRIPTOR *mem_map_ptr = 0;
    UINTN map_key;
    UINTN descriptor_size;
    UINT32 descriptor_version = 1;

    // get the memory map size
    result = SystemTable->BootServices->GetMemoryMap(
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
        result = SystemTable->BootServices->AllocatePool(
            EfiLoaderCode,
            mem_map_size,
            &buffer
        );

        // get memory map
        GetMemoryMap_result = SystemTable->BootServices->GetMemoryMap(
            &mem_map_size,
            mem_map_ptr,
            &map_key,
            &descriptor_size,
            &descriptor_version
        );

        // if GetMemoryMap() failed, free pool and try again
        if (GetMemoryMap_result != EFI_SUCCESS){
            result = SystemTable->BootServices->FreePool(&buffer);
        }
    }
    while (GetMemoryMap_result != EFI_SUCCESS);

    // exit efi
    result = SystemTable->BootServices->ExitBootServices(ImageHandle, map_key);

    return result;
}