In this folder, you can place the additional contents you want to add into WinPE.

Under WinPEExt\drivers, place the platform specific drivers that needs to be installed in WinPE.
Under WinPEExt\recovery, place your platform specific recovery hooks here. You can
  - add a pre_recovery_hook.cmd - this should return 0 to continue and 1 to skip recovery 
  - add a post_recovery_hook.cmd, this is invoked after recovery of mainos/data/efiesp wims are done
  - add a recoverygui.exe that is launched when WinPE is launched.
 See Templates\recovery\startnet.cmd for more details.
