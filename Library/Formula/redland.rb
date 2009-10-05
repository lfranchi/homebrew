require 'brewkit'

class Redland <Formula
  @url='http://download.librdf.org/source/redland-1.0.9.tar.gz'
  @homepage='http://librdf.org/'
  @md5='e5ef0c29c55b4f0f5aeed7955b4d383b'

  depends_on 'raptor'
  depends_on 'rasqal'

  def install
    # fails with llvm :-/
    ENV.gcc_4_2
    
    # fails when including /usr/include/sqlite3.h 
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--with-sqlite=no"
    system "make install"
  end
end
