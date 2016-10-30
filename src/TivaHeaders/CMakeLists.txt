MESSAGE(STATUS "\n Checking ${CMAKE_CURRENT_SOURCE_DIR}")

# Header only install 
SET(COMPONENT_NAME "TivaHeaders")
SET(LIBRARY_NAME ${COMPONENT_NAME})
#string(TOLOWER ${COMPONENT_NAME} LIBRARY_NAME)

# For now same version as the whole project
SET(COMPONENT_VERSION 2.1.3 )

set(generated_dir "${CMAKE_BINARY_DIR}/generated")
set(version_config "${generated_dir}/${COMPONENT_NAME}ConfigVersion.cmake")
set(component_config "${generated_dir}/${COMPONENT_NAME}Config.cmake")
set(targets_export_name "${COMPONENT_NAME}Targets")
set(namespace "${PROJECT_NAMESPACE}")


string(TOLOWER ${TIVA_PART_NAME} DEVICE_HEADER)

#------------------------------
# normal sources
#------------------------------
set(SRCS
  ${PROJECT_INCLUDE_DIR}/inc/${DEVICE_HEADER}.h
  )

#------------------------------
# Output a library
#------------------------------
ADD_LIBRARY(${LIBRARY_NAME} ${SRCS})

# Header only pseudo library
SET_TARGET_PROPERTIES(
  ${LIBRARY_NAME} PROPERTIES
  COMPILE_DEFINITIONS PART_${TIVA_PART_NAME}
  LINKER_LANGUAGE C
  )


target_include_directories(
  ${LIBRARY_NAME}
  PRIVATE
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}>
  PUBLIC
  $<BUILD_INTERFACE:${PROJECT_INCLUDE_DIR}/${namespace}>
  )


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

# TivaWare/TivaHeadersConfig.cmake
configure_file("${CMAKE_SOURCE_DIR}/cmake/Config.cmake.in"
  "${component_config}" @ONLY)

INSTALL(TARGETS ${LIBRARY_NAME}
  EXPORT ${targets_export_name}
  COMPONENT DEVELOP
  ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
  LIBRARY DESTINATION ${INSTALL_LIB_DIR}
  RUNTIME DESTINATION ${INSTALL_BIN_DIR}
  # this will add -I<prefix>/include/TivaWare to client compile flags
#  INCLUDES DESTINATION ${INSTALL_INCLUDE_DIR}/${namespace}
  )

# Generic TivaWare headers
INSTALL(DIRECTORY
  ${PROJECT_INCLUDE_DIR}/inc
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
