# Lab3
At this lab, we need to implement cache in a system with CPU in Lab 1、 AXI bus in Lab2.

    SPEC:
    1、1KB
    2、128 bits per line
    3、Directed map
    4、hit -> write through、miss -> write around

    In a one-way typical cache structure what we has to implement are:

    1、tag RAM
      the tag ram has 64 entries and 22bits for each entry

    2、valid RAM
      the valid ram has 64 entries

    3、data RAM
      the data ram has 64 entries and 128bits (4words) for each entry

    4、comparator
    5、control unit
    
    
    ports naming :
    ![mage](https://user-images.githubusercontent.com/71488907/201461475-80f87e69-b931-47fc-8c3d-9ce97b49bc74.jpg)

