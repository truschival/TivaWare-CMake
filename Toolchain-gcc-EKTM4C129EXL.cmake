# this one is important
SET(CMAKE_SYSTEM_NAME Generic)

SET(CMAKE_SYSTEM_PROCESSOR arm)
SET(CMAKE_CROSSCOMPILING 1)
SET(CMAKE_SYSTEM_VERSION 2.0.1)

# Cross-Compile Prefix
SET(TOOLCHAIN_PATH  "/opt/gcc-arm-none-eabi-4_9-2014q4/arm-none-eabi/"
  CACHE PATH "Toolchain install dir" FORCE)

SET(CROSS_COMPILE  "arm-none-eabi-" CACHE STRING "Architecture prefix including dash (-)" FORCE)

# Board name for local component dir 
SET(BOARD  "EK_TM4C129EXL" CACHE STRING "Board identification" FORCE)

# TivaWare Compilation  settings
SET(TIVA_PART_NAME  "TM4C129ENCPDT" CACHE STRING "TivaWare compilation flag -DPART_..." FORCE)
SET(TIVA_TARGET  "TARGET_IS_TM4C129_RA0" CACHE STRING "TivaWare compilation flag -DTARGET_IS..." FORCE)

# Some stripped down version of a sysroot i.e. where to find libraries
SET(COMPONENT_DIR "/home/ruschi/Coding/Components/${BOARD}"
  CACHE STRING "Additional libraries" FORCE)

# Append staging dir (where make install puts the packages)
SET(STAGING_DIR "/home/ruschi/tmp/${BOARD}" CACHE STRING "temporary rootfs")

#Default to Release-Build
IF(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE Release
        CACHE STRING "Choose the type of build : Debug Release"
        FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)


# specify the cross compiler
SET(CMAKE_C_COMPILER   "/opt/gcc-arm-none-eabi-4_9-2014q4/bin/${CROSS_COMPILE}gcc" )
SET(CMAKE_CXX_COMPILER "/opt/gcc-arm-none-eabi-4_9-2014q4/bin/${CROSS_COMPILE}g++" )
SET(CMAKE_ASM_COMPILER "/opt/gcc-arm-none-eabi-4_9-2014q4/bin/${CROSS_COMPILE}as")

set(CMAKE_EXECUTABLE_SUFFIX_CXX ".afx")
set(CMAKE_EXECUTABLE_SUFFIX_C ".afx")

# Do NOT treat imported headers / packages as "System" headers
# if this is not set import package header directories are pulled in with -isystem
SET(CMAKE_NO_SYSTEM_FROM_IMPORTED true)

# Where to look for libraries and headers
SET(CMAKE_FIND_ROOT_PATH  "/opt/gcc-arm-none-eabi-4_9-2014q4/arm-none-eabi/;${COMPONENT_DIR}")
# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Configuration macros for TivaWare Compilation
LIST(APPEND GNU_LAUNCHPAD_TARGET_DEFINITIONS ${TIVA_PART_NAME})
LIST(APPEND GNU_LAUNCHPAD_TARGET_DEFINITIONS ${TIVA_TARGET})
LIST(APPEND GNU_LAUNCHPAD_TARGET_DEFINITIONS "ARM_MATH_CM4") # not in tiva ware


SET(GNU_WARNING_FLAGS " -Wall -Wextra " )
SET(GNU_TARGET_FLAGS  " -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp \
	-DPART_${TIVA_PART_NAME} -DARM_MATH_CM4 -D${TIVA_TARGET}")
SET(GNU_OPT_FLAGS " -ffunction-sections -fdata-sections ")

set(GNU_CXX_FLAGS "${GNU_WARINIG_FLAGS} ${GNU_TARGET_FLAGS} ${GNU_OPT_FLAGS}")
set(GNU_C_FLAGS "${GNU_WARNING_FLAGS}  ${GNU_TARGET_FLAGS}  ${GNU_OPT_FLAGS}")


SET(CMAKE_C_FLAGS_INIT
  " ${GNU_C_FLAGS} "
  CACHE STRING "C flags (from toolchain file)" )
SET(CMAKE_CXX_FLAGS_INIT
  " ${GNU_CXX_FLAGS} "
  CACHE STRING "CXX flags (from toolchain file)"
  )

SET(CMAKE_C_FLAGS_RELEASE_INIT
  " ${GNU_C_FLAGS} -Os ")
SET(CMAKE_CXX_FLAGS_RELEASE_INIT
  " ${GNU_CXX_FLAGS} -Os "
  )

SET(CMAKE_C_FLAGS_DEBUG_INIT
  " ${GNU_C_FLAGS} -O0 -g3 "
  )
SET(CMAKE_CXX_FLAGS_DEBUG_INIT
  " ${GNU_CXX_FLAGS}  -O0 -g3 "
  )

SET(CMAKE_EXE_LINKER_FLAGS_INIT
  " --specs=nosys.specs -Wl,--gc-sections -Wl,--static -Wl,--entry=ResetISR")



#--------------------------------------------------------------------------------
# Append Components to PREFIX PATH
#--------------------------------------------------------------------------------

# Add compiler libraries search path
LIST(APPEND CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PATH}")

MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

SET(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")

SUBDIRLIST(SUBDIRS ${COMPONENT_DIR}/${BOARD})
FOREACH(subdir ${SUBDIRS})
      LIST(APPEND CMAKE_PREFIX_PATH ${COMPONENT_DIR}/${BOARD}/${subdir})
ENDFOREACH()

SUBDIRLIST(SUBDIRS ${STAGING_DIR}/${BOARD})
FOREACH(subdir ${SUBDIRS})
      LIST(APPEND CMAKE_PREFIX_PATH ${STAGING_DIR}/${BOARD}/${subdir})
ENDFOREACH()

# Append staging dir (where make install puts the packages)
LIST(APPEND CMAKE_PREFIX_PATH ${STAGING_DIR})

# Strip duplicates
LIST(REMOVE_DUPLICATES CMAKE_PREFIX_PATH)

MESSAGE(STATUS " CMAKE_PREFIX_PATH : ${CMAKE_PREFIX_PATH}" )
