#mkdir -pv /ramfs
#mount -t ramfs -o size=20g ramfs /ramfs
#第一个"ramfs"指的是文件系统的类型，它告诉系统要去挂载的是一个类型为ramfs的文件系统。
#第二个"ramfs"是设备名称，由于ramfs实际是内存而非物理设备，此处的名字并无特殊含义，可以是任何东西；不过通常为了保持清晰，我们还是用"ramfs"。
#第三个"/ramfs"是挂载点，即把ramfs文件系统挂载到哪个路径下。这将决定你如何访问该文件系统，比如上一步创建的目录"/ramfs"。
#要卸载的话：
#umount /ramfs

apt-get install -y inotify-tools --allow-unauthenticated
