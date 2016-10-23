MESSAGE(STATUS "\n Checking ${CMAKE_CURRENT_SOURCE_DIR}\n")

# Here the component/package will be called TivaWare (see project)
SET(COMPONENT_NAME "driverlib")
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
#------------------------------

# No dependencies so far
SET(MODULE_DEPS "")

#------------------------------
# normal sources
#------------------------------
set(SRCS
  ${CMAKE_CURRENT_SOURCE_DIR}/adc.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/aes.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/can.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/comp.c       
  ${CMAKE_CURRENT_SOURCE_DIR}/cpu.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/crc.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/des.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/eeprom.c     
  ${CMAKE_CURRENT_SOURCE_DIR}/emac.c       
  ${CMAKE_CURRENT_SOURCE_DIR}/epi.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/flash.c      
  ${CMAKE_CURRENT_SOURCE_DIR}/fpu.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/gpio.c       
  ${CMAKE_CURRENT_SOURCE_DIR}/hibernate.c  
  ${CMAKE_CURRENT_SOURCE_DIR}/i2c.c        
  ${CMAKE_CURRENT_SOURCE_DIR}/interrupt.c  
  ${CMAKE_CURRENT_SOURCE_DIR}/lcd.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/mpu.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/onewire.c 
  ${CMAKE_CURRENT_SOURCE_DIR}/pwm.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/qei.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/shamd5.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/ssi.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/sw_crc.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/sysctl.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/sysexc.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/systick.c 
  ${CMAKE_CURRENT_SOURCE_DIR}/timer.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/uart.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/udma.c	 
  ${CMAKE_CURRENT_SOURCE_DIR}/usb.c	   
  ${CMAKE_CURRENT_SOURCE_DIR}/watchdog.c
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
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}/${LIBRARY_NAME}>
  PUBLIC
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}>
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
  INCLUDES DESTINATION ${INSTALL_INCLUDE_DIR}
  )

INSTALL(DIRECTORY
  ${PROJECT_INCLUDE_DIR}/${LIBRARY_NAME}
  COMPONENT DEVELOP
  DESTINATION ${INSTALL_INCLUDE_DIR}
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
