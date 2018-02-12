self: super:
(import ./st self super) //
{ rocketchat = super.callPackage ./rocketchat-desktop {}; }
