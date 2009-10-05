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
  # dont link/build kautomounter and things that reference it
  def patches
    DATA
  end
  
  def install
    FileUtils.mkdir 'kdelibs-build'

    Dir.chdir 'kdelibs-build' do
        system "cmake .. #{std_cmake_parameters} -DBUNDLE_INSTALL_DIR=#{bin}"
        
        #ugh. why can't cmake detect this right?
        inreplace CMakeCache, "HAVE_FDATASYNC:INTERNAL=1", "HAVE_FDATASYNC:INTERNAL=0"
        
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
--- a/kio/kio/kdesktopfileactions.cpp	(revision 1031425)
+++ b/kio/kio/kdesktopfileactions.cpp	(working copy)
@@ -105,7 +105,7 @@
         if ( fstype == "Default" ) // KDE-1 thing
             fstype.clear();
         QString point = cg.readEntry( "MountPoint" );
-#ifndef Q_WS_WIN
+#ifdef Q_WS_X11
         (void) new KAutoMount( ro, fstype.toLatin1(), dev, point, _url.path() );
 #endif
         retval = false;
@@ -294,7 +294,7 @@
                 if ( fstype == "Default" ) // KDE-1 thing
                     fstype.clear();
                 QString point = group.readEntry( "MountPoint" );
-#ifndef Q_WS_WIN
+#ifdef Q_WS_X11
                 (void)new KAutoMount( ro, fstype.toLatin1(), dev, point, path, false );
 #endif
             } else if ( actionData == ST_UNMOUNT ) {
@@ -302,7 +302,7 @@
                 if ( !mp )
                     return;
 
-#ifndef Q_WS_WIN
+#ifdef Q_WS_X11
                 (void)new KAutoUnmount( mp->mountPoint(), path );
 #endif
             }
--- a/kio/kio/kfileitem.cpp	(revision 1031425)
+++ b/kio/kio/kfileitem.cpp	(working copy)
@@ -834,7 +834,7 @@
         names.append("hidden");
     }
 
-#ifndef Q_OS_WIN
+#ifdef Q_WS_X11
     if( S_ISDIR( d->m_fileMode ) && d->m_bIsLocalUrl)
     {
         if (KSambaShare::instance()->isDirectoryShared( d->m_url.toLocalFile() ) ||
--- a/kio/CMakeLists.txt	(revision 1031425)
+++ b/kio/CMakeLists.txt	(working copy)
@@ -137,13 +137,13 @@
 qt4_add_dbus_interface(kiocore_STAT_SRCS kio/org.kde.KPasswdServer.xml kpasswdserver_interface)
 install(FILES kio/org.kde.KPasswdServer.xml DESTINATION ${DBUS_INTERFACES_INSTALL_DIR})
 
-if(UNIX)
+if(LINUX)
    set(kiocore_STAT_SRCS ${kiocore_STAT_SRCS}
        kio/kautomount.cpp
        kio/knfsshare.cpp
        kio/ksambashare.cpp
    )
-endif(UNIX)
+endif(LINUX)
 
 if(WIN32)
    set(kiocore_STAT_SRCS ${kiocore_STAT_SRCS}
--- a/kdewidgets/makekdewidgets.cpp	2009-09-13 13:08:08.000000000 -0400
+++ b/kdewidgets/makekdewidgets.cpp	2009-10-04 23:49:36.000000000 -0400
@@ -28,7 +28,6 @@
 static const char collClassDef[] = "class %CollName : public QObject, public QDesignerCustomWidgetCollectionInterface\n"
                                 "{\n"
                                 "	Q_OBJECT\n"
-                                "	Q_INTERFACES(QDesignerCustomWidgetCollectionInterface)\n"
                                 "public:\n"
                                 "	%CollName(QObject *parent = 0);\n"
                                 "	virtual ~%CollName() {}\n"
@@ -50,7 +49,6 @@
 static const char classDef[] =  "class %PluginName : public QObject, public QDesignerCustomWidgetInterface\n"
                                 "{\n"
                                 "	Q_OBJECT\n"
-                                "	Q_INTERFACES(QDesignerCustomWidgetInterface)\n"
                                 "public:\n"
                                 "	%PluginName(QObject *parent = 0) :\n\t\tQObject(parent), mInitialized(false) {}\n"
                                 "	virtual ~%PluginName() {}\n"
