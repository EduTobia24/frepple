# Windows installer packaging

if(WIN32)
  # Find Inno Setup compiler
  find_program(INNO_SETUP 
    NAMES ISCC.exe 
    PATHS 
      "C:/Program Files (x86)/Inno Setup 6"
      "C:/Program Files/Inno Setup 6"
      "$ENV{ProgramFiles}/Inno Setup 6"
      "$ENV{ProgramFiles\(x86\)}/Inno Setup 6"
  )

  if(INNO_SETUP)
    message(STATUS "Found Inno Setup: ${INNO_SETUP}")
    
    # Create custom target for Windows installer
    add_custom_target(windows_installer
      COMMAND ${INNO_SETUP} "${CMAKE_CURRENT_SOURCE_DIR}/frepple-installer.iss"
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
      COMMENT "Building Windows installer with Inno Setup..."
      VERBATIM
    )
    
    # Add dependencies - ensure binaries are built first
    add_dependencies(windows_installer frepple frepple-main)
    
    message(STATUS "Windows installer target added. Build with: cmake --build . --target windows_installer")
  else()
    message(WARNING "Inno Setup not found. Windows installer cannot be built.")
    message(WARNING "Download from: https://jrsoftware.org/isdl.php")
  endif()
  
  # Install scripts
  install(
    DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/scripts/"
    DESTINATION "${CMAKE_INSTALL_BINDIR}/../scripts"
    FILES_MATCHING PATTERN "*.bat"
    PERMISSIONS OWNER_EXECUTE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_READ
  )
  
  # Install README
  install(
    FILES "${CMAKE_CURRENT_SOURCE_DIR}/README.txt"
    DESTINATION "."
  )
  
endif()
