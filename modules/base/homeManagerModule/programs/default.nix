/*
  NOTE:
    카테고리는 <https://wiki.archlinux.org/title/List_of_applications> 에서 따왔다.
*/
{ ... }:
{
  imports = [
    ./00-shell
    ./10-console-tools
    ./70-dev
    ./80-documents
    ./80-internet
    ./80-multimedia
    ./80-others
    ./80-utilities
  ];
}
