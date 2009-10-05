require 'brewkit'

class Kdelibs <Formula
  @head='svn://anonsvn.kde.org/home/kde/trunk/KDE/kdelibs'
  homepage 'http://www.kde.org'

  depends_on 'cmake'
  depends_on 'qt'
  depends_on 'kdesupport'
  depends_on 'pcre'
  depends_on 'jpeg'
  depends_on 'gif'
  depends_on 'qca'
  
  # fix finding of frameworks on osx
  def patches
    DATA
  end
  
  def install
    FileUtils.mkdir 'kdelibs-build'

    Dir.chdir 'kdelibs-build' do
        system "cmake .. #{std_cmake_parameters}"
        system "make install"    
      end    
    system "make install"
  end
end
__END__
--- a/cmake/modules/FindKDE4Internal.cmake	(revision 1023159)
+++ b/cmake/modules/FindKDE4Internal.cmake	(working copy)
@@ -1126,14 +1126,13 @@
    endif (GCC_IS_NEWER_THAN_4_1)
 
    if (__KDE_HAVE_GCC_VISIBILITY AND GCC_IS_NEWER_THAN_4_1 AND NOT _GCC_COMPILED_WITH_BAD_ALLOCATOR AND NOT WIN32)
-      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
-      set (KDE4_C_FLAGS "-fvisibility=hidden")
+      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden -F${QT_LIBRARY_DIR}")
+      set (KDE4_C_FLAGS "-fvisibility=hidden -F${QT_LIBRARY_DIR}")
       # check that Qt defines Q_DECL_EXPORT as __attribute__ ((visibility("default")))
       # if it doesn't and KDE compiles with hidden default visibiltiy plugins will break
       set(_source "#include <QtCore/QtGlobal>\n int main()\n {\n #ifdef QT_VISIBILITY_AVAILABLE \n return 0;\n #else \n return 1; \n #endif \n }\n")
       set(_source_file ${CMAKE_BINARY_DIR}/CMakeTmp/check_qt_visibility.cpp)
       file(WRITE "${_source_file}" "${_source}")
-      set(_include_dirs "-DINCLUDE_DIRECTORIES:STRING=${QT_INCLUDES}")
 
       try_run(_run_result _compile_result ${CMAKE_BINARY_DIR} ${_source_file} CMAKE_FLAGS "${_include_dirs}" COMPILE_OUTPUT_VARIABLE _compile_output_var)
 

