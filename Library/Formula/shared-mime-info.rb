require 'brewkit'

class SharedMimeInfo <Formula
  url 'http://ftp.osuosl.org/pub/blfs/svn/s/shared-mime-info-0.60.tar.bz2'
  md5 '339b8c284a3b7c153adea985b419030e'
  homepage 'http://www.freedesktop.org/wiki/Software/shared-mime-info'

 depends_on 'intltool'
 depends_on 'gettext'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
#   system "cmake . #{std_cmake_parameters}"
    system "make install"
  end
end
