require 'brewkit'

class Dbus <Formula
  url 'http://dbus.freedesktop.org/releases/dbus/dbus-1.2.16.tar.gz'
  homepage 'http://www.freedesktop.org/wiki/Software/dbus'
  md5 'c7a47b851ebe02f6726b65b78d1b730b'

# depends_on 'cmake'
  def patches
    'http://gist.github.com/raw/201422/ed32db785476e7a21bca7dbd17bdbd8e8a482d53/dbus-launchd-integration-1.2.16.patch'
  end

  def install
    system "autoreconf -fvi"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-doxygen-docs",
                          "--disable-xml-docs",
                          "--without-x",
                          "--enable-launchd",
                          "--with-dbus-user=messagebus",
                          "--with-launchd-agent-dir=#{prefix}/Library/LaunchAgents",
                          "--with-dbus-daemondir=#{bin}"
            
    inreplace "dbus/dbus-sysdeps-unix.c", "/usr/local", "#{prefix}"
    inreplace "configure", "broken_poll=\"no (cross compiling)\"", "broken_poll=yes"
    # don't want /g, so call it ourselves
    #safe_system "/usr/bin/perl", "-pi", "-e", "s/<false \\/>/<false \\/>\\n\n\\t<key>Disabled<\\/key>\\n\\t<true\\/>/", "bus/org.freedesktop.dbus-session.plist.in"
    #safe_system "/usr/bin/perl", "-pi", "-e", "s/<false \\/>/<true \\/>/", "bus/org.freedesktop.dbus-session.plist.in"
    
#   system "cmake . #{std_cmake_parameters}"
    system "make install"
      
    # make the two .plist files
    #(prefix + "Library" + "LaunchAgents" + "org.freedesktop.dbus-session.plist").write SESSION_PLIST
    
    
    (prefix + "Library" + "LaunchDaemons" + "org.freedesktop.dbus-system.plist").write <<-EOF
    <?xml version='1.0' encoding='UTF-8'?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd" >
    <plist version='1.0'>
    <dict>
    <key>Label</key><string>org.freedesktop.dbus-system</string>
    <key>ProgramArguments</key>
    <array>
            <string>#{bin}/dbus-daemon</string>
            <string>--system</string>
            <string>--nofork</string>
    </array>
    <key>OnDemand</key><false/>
    <key>Disabled</key><true/>
    </dict>
    </plist>
    EOF
    
  end
  
  def caveats; <<-EOF 
    The dbus system bus can auto-start with OS X, but it requires a symlink in your system library dir.
    Run the next two commands to hook things up:
  
    sudo ln -s #{prefix}/Library/LaunchAgents/org.freedesktop.dbus-session.plist /Library/LaunchAgents/org.freedesktop.dbus-session.plist
    sudo ln -s #{prefix}/Library/LaunchDaemons/org.freedesktop.dbus-system.plist /Library/LaunchDaemons/org.freedesktop.dbus-system.plist
  
    You will also need to make the two launchd files owned by root, othewise os x will complain:
    sudo chown root:admin #{prefix}/Library/LaunchAgents/org.freedesktop.dbus-session.plist
    sudo chown root:admin #{prefix}/Library/LaunchDaemons/org.freedesktop.dbus-system.plist
  
    You can manually start the dbus service by doing: 
      sudo launchctl load /Library/LaunchAgents/org.freedesktop.dbus-session.plist
    but it will autostart when  needed from the next reboot.
  
    EOF
  end

end