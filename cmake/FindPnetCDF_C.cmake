# - Try to find PnetCDF C Libraries
#
# This can be controlled by setting the PnetCDF_DIR CMake variable, or the
# PNETCDF environment variable.
#
# Once done, this will define:
#
#   PnetCDF_C_IS_SHARED    (BOOL) - whether the PnetCDF library is shared/dynamic
#
#   PnetCDF_C_FOUND        (BOOL) - system has PnetCDF
#   PnetCDF_C_INCLUDE_DIR  (PATH) - Location of the PnetCDF C header
#   PnetCDF_C_INCLUDE_DIRS (LIST) - the NetCDF include directories
#   PnetCDF_C_LIBRARY      (FILE) - Full path to PnetCDF C library file
#   PnetCDF_C_LIBRARIES    (LIST) - link these to use PnetCDF
#   PnetCDF_C_DEFINITIONS  (LIST) - preprocessor macros to use with PnetCDF
#   PnetCDF_C_OPTIONS      (LIST) - compiler options to use PnetCDF


# Determine include dir search order
set (PnetCDF_C_INCLUDE_HINTS)
if (PnetCDF_C_INCLUDE_DIR)
    list (APPEND PnetCDF_C_INCLUDE_HINTS ${PnetCDF_C_INCLUDE_DIR})
endif ()
if (PnetCDF_DIR)
    list (APPEND PnetCDF_C_INCLUDE_HINTS ${PnetCDF_DIR}/include)
endif ()
if (DEFINED ENV{PNETCDF})
    list (APPEND PnetCDF_C_INCLUDE_HINTS $ENV{PNETCDF}/include)
endif ()

# Search for C include file
find_path (PnetCDF_C_INCLUDE_DIR
           NAMES pnetcdf.h
           HINTS ${PnetCDF_C_INCLUDE_HINTS})

# Unset include search variables
unset (PnetCDF_C_INCLUDE_HINTS)

# Determine library dir search order
set (PnetCDF_C_LIBRARY_HINTS)
if (PnetCDF_C_LIBRARY)
    get_filename_component (pnetcdf_library_path ${PnetCDF_C_LIBRARY} PATH)
    list (APPEND PnetCDF_C_LIBRARY_HINTS ${pnetcdf_library_path})
    unset (pnetcdf_library_path)
endif ()
if (PnetCDF_DIR)
    list (APPEND PnetCDF_C_LIBRARY_HINTS ${PnetCDF_DIR}/lib)
endif ()
if (DEFINED ENV{PNETCDF})
    list (APPEND PnetCDF_C_LIBRARY_HINTS $ENV{PNETCDF}/lib)
endif ()

# Search for shared and static library files
set (PnetCDF_C_IS_SHARED FALSE)
find_library (PnetCDF_C_LIBRARY
              NAMES pnetcdf
              HINTS ${PnetCDF_C_LIBRARY_HINTS})
if (PnetCDF_C_LIBRARY)
    set (PnetCDF_C_IS_SHARED TRUE)
else ()
    find_library (PnetCDF_C_LIBRARY
                  NAMES libpnetcdf.a
                  HINTS ${PnetCDF_C_LIBRARY_HINTS})
endif ()

# Unset include search variables
unset (PnetCDF_C_LIBRARY_HINTS)

# Set C-language return variables
set (PnetCDF_C_INCLUDE_DIRS ${PnetCDF_C_INCLUDE_DIR})
set (PnetCDF_C_LIBRARIES ${PnetCDF_C_LIBRARY})
set (PnetCDF_C_DEFINITIONS)
set (PnetCDF_C_OPTIONS)

# Set Fortran-language return variables
set (PnetCDF_Fortran_INCLUDE_DIRS ${PnetCDF_Fortran_INCLUDE_DIR})
set (PnetCDF_Fortran_LIBRARIES ${PnetCDF_C_LIBRARY})
set (PnetCDF_Fortran_DEFINITIONS)
set (PnetCDF_Fortran_OPTIONS)

# If static, look for dependencies
if (NOT PnetCDF_C_IS_SHARED)

    # Dependency find_package arguments
    set (find_args)
    if (PnetCDF_C_FIND_REQUIRED)
        list (APPEND find_args REQUIRED)
    endif ()
    if (PnetCDF_C_FIND_QUIETLY)
        list (APPEND find_args QUIET)
    endif ()

    # DEPENDENCY: MPI
    find_package (MPI ${find_args})
    if (MPI_C_FOUND)
        list (APPEND PnetCDF_C_INCLUDE_DIRS ${MPI_C_INCLUDE_PATH})
        list (APPEND PnetCDF_C_LIBRARIES ${MPI_C_LIBRARIES})
        list (APPEND PnetCDF_C_OPTIONS ${MPI_C_COMPILE_FLAGS})
    endif ()

endif ()

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and 
# set PnetCDF_C_FOUND to TRUE if all listed variables are TRUE
find_package_handle_standard_args (PnetCDF_C DEFAULT_MSG
                                   PnetCDF_C_LIBRARY PnetCDF_C_INCLUDE_DIR)
mark_as_advanced (PnetCDF_C_INCLUDE_DIR PnetCDF_C_LIBRARY)

# HACK For bug in CMake v3.0:
set (PnetCDF_C_FOUND ${PNETCDF_C_FOUND})
