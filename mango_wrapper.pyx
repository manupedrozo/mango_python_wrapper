#cython: language_level=3

cimport cmango
from enum import Enum
from libc.stdint cimport uint32_t
from libc.stdlib cimport malloc, free

def str_encode(s: str) -> bytes:
    return s.encode('UTF-8')

def str_decode(b: bytes) -> str:
    return b.decode('UTF-8')

# mango
cdef class kernelfunction:
    cdef cmango.kernelfunction *ptr

    def __init__(self, *args):
        raise TypeError('Cannot create instance from Python')

    @staticmethod
    cdef kernelfunction create(cmango.kernelfunction* ptr):
        obj = <kernelfunction>kernelfunction.__new__(kernelfunction)
        obj.ptr = ptr
        return obj

cdef class mango_task_graph_t:
    cdef cmango.mango_task_graph_t *ptr

    def __init__(self, *args):
        raise TypeError('Cannot create instance from Python')

    @staticmethod
    cdef mango_task_graph_t create(cmango.mango_task_graph_t* ptr):
        obj = <mango_task_graph_t>mango_task_graph_t.__new__(mango_task_graph_t)
        obj.ptr = ptr
        return obj


def mango_init(application_name: str, recipe: str) -> mango_exit_t:
    b_application_name = str_encode(application_name)
    b_recipe = str_encode(recipe)
    cdef cmango.mango_exit_t result = cmango.mango_init(b_application_name, b_recipe)
    return mango_exit_t(result)


def mango_release() -> None:
    result = cmango.mango_release()
    return mango_exit_t(result)

def mango_kernelfunction_init() -> kernelfunction:
    cdef cmango.kernelfunction *ptr = cmango.mango_kernelfunction_init()
    return kernelfunction.create(ptr)

def mango_load_kernel(kname: str, kernel: kernelfunction, unit: mango_unit_type_t, t: filetype) -> mango_exit_t:
    b_kname = str_encode(kname)
    check_type_mango_unit_type_t(unit)
    check_type_filetype(t)
    result = cmango.mango_load_kernel(b_kname, kernel.ptr, unit.value, t.value)
    return mango_exit_t(result) 

''' Segmentation fault (not implemented in mango.cpp)
def mango_deregister_kernel(kernel: uint32_t) -> None:
    cmango.mango_deregister_kernel(kernel)
'''

def mango_deregister_memory(mem: uint32_t) -> None:
    cmango.mango_deregister_memory(mem)

''' Segmentation fault (not implemented in mango.cpp)
def mango_deregister_event(event: uint32_t) -> None:
    cmango.mango_deregister_event(event)
'''

def mango_get_buffer_event(buffer: uint32_t) -> uint32_t:
    return cmango.mango_get_buffer_event(buffer)


''' Segmentation fault (not implemented in mango.cpp)
def mango_task_graph_vcreate(kernels: list, buffers: list, events: list) -> mango_task_graph_t:
    cdef uint32_t *kernels_array = <uint32_t *>malloc(len(kernels)*sizeof(uint32_t))
    if kernels_array is NULL:
        raise MemoryError()
    for i in range(len(kernels)):
        kernels_array[i] = kernels[i]

    cdef uint32_t *buffers_array = <uint32_t *>malloc(len(buffers)*sizeof(uint32_t))
    if buffers_array is NULL:
        raise MemoryError()
    for i in range(len(buffers)):
        buffers_array[i] = buffers[i]

    cdef uint32_t *events_array = <uint32_t *>malloc(len(events)*sizeof(uint32_t))
    if events_array is NULL:
        raise MemoryError()
    for i in range(len(events)):
        events_array[i] = events[i]

    cdef cmango.mango_task_graph_t *ptr = cmango.mango_task_graph_vcreate(&kernels_array, &buffers_array, &events_array)

    free(kernels_array)
    free(buffers_array)
    free(events_array)

    return mango_task_graph_t.create(ptr)
'''
 


# mango_types_c

class mango_exit_t(Enum):
    SUCCESS                     = cmango.mango_exit_t.SUCCESS
    ERR_INVALID_VALUE           = cmango.mango_exit_t.ERR_INVALID_VALUE
    ERR_INVALID_TASK_ID         = cmango.mango_exit_t.ERR_INVALID_TASK_ID
    ERR_INVALID_KERNEL          = cmango.mango_exit_t.ERR_INVALID_KERNEL
    ERR_FEATURE_NOT_IMPLEMENTED = cmango.mango_exit_t.ERR_FEATURE_NOT_IMPLEMENTED
    ERR_INVALID_KERNEL_FILE     = cmango.mango_exit_t.ERR_INVALID_KERNEL_FILE
    ERR_UNSUPPORTED_UNIT        = cmango.mango_exit_t.ERR_UNSUPPORTED_UNIT
    ERR_OUT_OF_MEMORY           = cmango.mango_exit_t.ERR_OUT_OF_MEMORY
    ERR_SEM_FAILED              = cmango.mango_exit_t.ERR_SEM_FAILED
    ERR_MMAP_FAILED             = cmango.mango_exit_t.ERR_MMAP_FAILED
    ERR_FOPEN                   = cmango.mango_exit_t.ERR_FOPEN
    ERR_OTHER                   = cmango.mango_exit_t.ERR_OTHER

def check_type_mango_exit_t(e: mango_exit_t) -> None:
    if not isinstance(e, mango_exit_t):
         raise TypeError("mango_exit_t required")


class mango_event_status_t(Enum):
    LOCK               = cmango.mango_event_status_t.LOCK
    READ               = cmango.mango_event_status_t.READ
    WRITE              = cmango.mango_event_status_t.WRITE
    END_FIFO_OPERATION = cmango.mango_event_status_t.END_FIFO_OPERATION 

def check_type_mango_event_status_t(e: mango_event_status_t) -> None:
    if not isinstance(e, mango_event_status_t):
         raise TypeError("mango_event_status_t required")


class filetype(Enum):
    UNKNOWN_KERNEL_SOURCE_TYPE = cmango.filetype.UNKNOWN_KERNEL_SOURCE_TYPE
    BINARY                     = cmango.filetype.BINARY
    HARDWARE                   = cmango.filetype.HARDWARE
    STRING                     = cmango.filetype.STRING
    SOURCE                     = cmango.filetype.SOURCE

def check_type_filetype(e: filetype) -> None:
    if not isinstance(e, filetype):
         raise TypeError("filetype required")


class mango_buffer_type_t(Enum):
    NONE   = cmango.mango_buffer_type_t.NONE
    FIFO   = cmango.mango_buffer_type_t.FIFO
    BUFFER = cmango.mango_buffer_type_t.BUFFER
    SCALAR = cmango.mango_buffer_type_t.SCALAR
    EVENT  = cmango.mango_buffer_type_t.EVENT

def check_type_mango_buffer_type_t(e: mango_buffer_type_t) -> None:
    if not isinstance(e, mango_buffer_type_t):
         raise TypeError("mango_buffer_type_t required")


class mango_unit_type_t(Enum):
    PEAK  = cmango.mango_unit_type_t.PEAK
    NUP   = cmango.mango_unit_type_t.NUP
    DCT   = cmango.mango_unit_type_t.DCT
    GN    = cmango.mango_unit_type_t.GN
    GPGPU = cmango.mango_unit_type_t.GPGPU
    ARM   = cmango.mango_unit_type_t.ARM
    STOP  = cmango.mango_unit_type_t.STOP

def check_type_mango_unit_type_t(e: mango_unit_type_t) -> None:
    if not isinstance(e, mango_unit_type_t):
         raise TypeError("mango_unit_type_t required")


class mango_communication_mode_t(Enum):
    DIRECT = cmango.mango_communication_mode_t.DIRECT
    BURST  = cmango.mango_communication_mode_t.BURST

def check_type_mango_communication_mode_t(e: mango_communication_mode_t) -> None:
    if not isinstance(e, mango_communication_mode_t):
         raise TypeError("mango_communication_mode_t required")
