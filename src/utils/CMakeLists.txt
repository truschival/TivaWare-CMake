MESSAGE(STATUS "\n Checking ${CMAKE_CURRENT_SOURCE_DIR}")

# Here the component/package will be called TivaWare (see project)
SET(COMPONENT_NAME "utils")
string(TOLOWER ${COMPONENT_NAME} LIBRARY_NAME)

# For now same version as the whole project
SET(COMPONENT_VERSION 2.1.3 )

set(generated_dir "${CMAKE_BINARY_DIR}/generated")
set(version_config "${generated_dir}/${COMPONENT_NAME}ConfigVersion.cmake")
set(component_config "${generated_dir}/${COMPONENT_NAME}Config.cmake")
set(targets_export_name "${COMPONENT_NAME}Targets")
set(namespace "${PROJECT_NAMESPACE}")

#------------------------------
# Dependencies
# utils depend on drivers
# drivers depend on driverlib. 
#------------------------------

if(TARGET driverlib)
  add_library(TivaWare::driverlib ALIAS driverlib)
else() # Import it externally if not built before
    find_package(TivaWare COMPONENTS driverlib CONFIG REQUIRED)
endif()
LIST(APPEND MODULE_DEPS TivaWare::driverlib)


if(TARGET drivers)
  add_library(TivaWare::drivers ALIAS driverlib)
else() # Import it externally if not built before
    find_package(TivaWare COMPONENTS drivers CONFIG REQUIRED)
endif()
LIST(APPEND MODULE_DEPS TivaWare::drivers)


#------------------------------
# normal sources
#------------------------------
set(SRCS
  ${CMAKE_CURRENT_SOURCE_DIR}/cmdline.c
  ${CMAKE_CURRENT_SOURCE_DIR}/cpu_usage.c
  ${CMAKE_CURRENT_SOURCE_DIR}/eeprom_pb.c
  ${CMAKE_CURRENT_SOURCE_DIR}/flash_pb.c
  ${CMAKE_CURRENT_SOURCE_DIR}/isqrt.c
  ${CMAKE_CURRENT_SOURCE_DIR}/random.c
  ${CMAKE_CURRENT_SOURCE_DIR}/ringbuf.c
  ${CMAKE_CURRENT_SOURCE_DIR}/scheduler.c
  ${CMAKE_CURRENT_SOURCE_DIR}/sine.c
  ${CMAKE_CURRENT_SOURCE_DIR}/smbus.c
  ${CMAKE_CURRENT_SOURCE_DIR}/softi2c.c
  ${CMAKE_CURRENT_SOURCE_DIR}/softssi.c
  ${CMAKE_CURRENT_SOURCE_DIR}/softuart.c
  ${CMAKE_CURRENT_SOURCE_DIR}/spi_flash.c
  ${CMAKE_CURRENT_SOURCE_DIR}/uartstdio.c
  ${CMAKE_CURRENT_SOURCE_DIR}/ustdlib.c
  )

#------------------------------
# Output a library
#------------------------------
ADD_LIBRARY(${LIBRARY_NAME} ${SRCS})

SET_TARGET_PROPERTIES(
  ${LIBRARY_NAME} PROPERTIES
  #  COMPILE_DEFINITIONS "${ARDUINO_COMPILE_DEFINITIONS}"
  OUTPUT_NAME ${LIBRARY_NAME}
  VERSION ${LIBRARY_VERSION}
  SOVERSION ${LIBRARY_VERSION}
  )


target_include_directories(
  ${LIBRARY_NAME}
  PRIVATE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}>
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}/${LIBRARY_NAME}>
  PUBLIC
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}/${namespace}>
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}/${namespace}/${LIBRARY_NAME}>
  )

# Add dependencies to library to pass
# dependencies on to client executable
TARGET_LINK_LIBRARIES( ${LIBRARY_NAME}
    ${MODULE_DEPS}
    )

#-----

#-----
# Install Targets Library + Headers
#-----
MESSAGE(STATUS "** Generating Package Configurations **")

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${version_config}
  VERSION ${LIBRARY_VERSION}
  COMPATIBILITY SameMajorVersion
)

# Configure '<PROJECT-NAME>Config.cmake'
# Note: variable 'targets_export_name' used
configure_file("${CMAKE_SOURCE_DIR}/cmake/Config.cmake.in"
  "${component_config}" @ONLY)

INSTALL(TARGETS ${LIBRARY_NAME}
  EXPORT ${targets_export_name}
  COMPONENT DEVELOP
  ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
  LIBRARY DESTINATION ${INSTALL_LIB_DIR}
  RUNTIME DESTINATION ${INSTALL_BIN_DIR}
  # this will only add -I<prefix>/include to client compile flags
  # The users of the library have to #include "driverlib/Ledstrip.h"
  INCLUDES DESTINATION ${INSTALL_INCLUDE_DIR}/${namespace}
  )

INSTALL(DIRECTORY
  ${PROJECT_INCLUDE_DIR}/${LIBRARY_NAME}
  COMPONENT DEVELOP
  DESTINATION ${INSTALL_INCLUDE_DIR}/${namespace}
  )

INSTALL(
  EXPORT ${targets_export_name}
  COMPONENT DEVELOP
  NAMESPACE "${namespace}::"
  DESTINATION "${INSTALL_CMAKE_DIR}/${namespace}"
  )

INSTALL(
  FILES "${component_config}" "${version_config}"
  COMPONENT DEVELOP
  DESTINATION "${INSTALL_CMAKE_DIR}/${namespace}"
  )
