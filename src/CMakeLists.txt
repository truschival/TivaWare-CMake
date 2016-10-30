MESSAGE(STATUS "\n Checking ${CMAKE_CURRENT_SOURCE_DIR}")

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/TivaHeaders/)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/driverlib/)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/drivers/)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/utils/)


