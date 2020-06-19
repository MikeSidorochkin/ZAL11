*&---------------------------------------------------------------------*
*& Program : ZAL11
*& Author  : S. Hermann
*& Date    : 28.11.2016
*& Version : 2.4.3
*&---------------------------------------------------------------------*
*& This program extend AL11 basics functions :
*& - Navigate in remote folders with graphic interface
*& - Sort & filter your remote file/folder
*& - Open remote file on your computer with default application
*&   (excel...), with your text editor or any application you want
*& - Upload/download files by button or drag/drop
*& - Manage file and folder (create, rename, remove, copy, move) with
*&   button and/or by drag&drop
*& - Open server shortcut & path from clipboard
*& - Manage server shortcut (create & delete)
*& - Copy path (server/local) to clipboard
*& - Compress remote file (TAR+BZ2)
*& - Uncompress remote file (ZIP & TAR & GZ & BZ2)
*& - CHMOD on file/folder (seem not work on folder)
*& - Access to remote server //servername/path/ using copy/paste
*&
*& Customization :
*&   You could customize how the program work easily using the fields
*&   of the structure s_customize
*&   It allow you
*&   ¤ To define a root path to restrict user acces
*&   ¤ To change the displayed root name
*&   ¤ To calculate folder size automatically (take time for root)
*&   ¤ To display system path shortcuts (usefull for system admin)
*&   ¤ To define authorisation object
*&   You could also desactivate globally any function of this program
*&   by changing the s_auth default value
*&
*& Security purpose :
*& - All modification on remote server require a user confirmation
*&   to avoid unwanted action
*& - You can define a root path to restrict acces
*& - You can manage which action is allowed by user
*&
*& This program is designed to run with a local pc under windows OS
*& and a remote server under unix/linux or Windows compatible OS.
*& If a different configuration is used, feel free to modify source
*& code.
*&
*& In some case (when application server is fast) the read process
*& after a remote server action give the old state of a folder
*& To be sure than C_DIR_READ_ give the correct folder content
*& a "wait up to 1 seconds" is added after each server action.
*& It's a dirty trick...
*&
*& Special thanks to Kay Streubel for his help on the windows version
*&
*& Please send comment & improvements to http://quelquepart.biz
*&---------------------------------------------------------------------*
*& Enhancement (todo list) :
*& - Find a way to force remote dir read refresh (to stop waiting 1 sec)
*& - Add more format to uncompress option (z, ...)
*& - Manage compression of folder and decompression (win server)
*& - Search on remote server function (find/grep)
*& - Add file management on local files/folder (nice to have)
*& - Have "properties" window on local/remote file
*&---------------------------------------------------------------------*
*& History :
*& 2016.11.28 v2.4.3: Fix-dump when "desktop" is a remote folder
*& 2016.04.18 v2.4.2: Fix-dump when refuse access with sapgui security
*& 2015.10.04 v2.4.1: Fix-Issue on upload/download ascii files
*& 2015.09.02 v2.4  : Fix-Issue on upload/download binary files
*&                    Fix-Issue with texts for "open as" and grid option
*&                    Add-Configuration to download file without popup
*&                    Mod-Rewrite all confirmations popup
*&                    Add-Allow user to delete shortcut
*&                    Mod-Display total line in first for remote grid
*&                    Mod-Code cleaning
*& 2015.08.07 v2.3.1: Add-Display number of file of current folder in
*&                        the sum line
*& 2015.06.19 v2.3  : Add-"Grid option" button to allow sort, filters...
*&                    Add-"Open as" on remote files
*& 2015.06.05 v2.2.2: Add-"Open as" on local files
*& 2014.11.18 v2.2.1: Add-Message if user deny access to his files
*& 2014.11.01 v2.2  : Add-Remember function for remote server connected
*& 2014.10.19 v2.1  : New-Calculation of folder size (auto/manual)
*&                    New-Allow distant server access (if root access)
*&                    New-Drop file/folder directly from grid to tree
*&                    New-Shortcuts for "System" folders
*& 2014.10.15 v2.0.1: Fix-Dump on windows server
*& 2014.10.11 v2.0  : New-Windows server managed
*&                    Mod-Rewrite of server command management
*&                    New-Desktop folder
*&                    New-Add dedicated icon on my documents folders
*&                    New-Attribute column on local grid and windows
*&                        remote grid
*&                    New-Change Attribute popup for windows server
*&                        files
*&                    Mod-Ask folder name when create new folder
*&                    Fix-Security issue on CHMOD
*&                    Fix-Recycle bin not always detected
*&                    Fix-"Last dir scan has not be finished" read error
*&                    Fix-Issue on huge file in remote folder
*&                    Fix-In some case shortcut button was not displayed
*&                    Mod-Easier customization of the program
*&                    Mod-Code cleaning
*& 2014.04.29 v1.4.2: Fix-Error in chmod type
*&                    New-Add owner name in chmod window
*& 2013.06.26 v1.4.1: New-Overwrite mode for upload (+new auth check)
*& 2013.04.20 v1.4  : New-CHMOD window
*& 2013.04.01 v1.3  : Fix-Blank line at end of file when open from serv.
*&                    Fix-Default mode for CSV file from BIN to ASC
*&                    New-Remind last used local/remote folder
*& 2013.01.24 v1.2  : New-Creation of server shortcut
*&                    New-Local shortcut to My Documents
*& 2013.01.09 v1.1.3: New-Add authority check S_C_FUNCT (call system)
*& 2012.05.08 v1.1.2: Fix-Allow long path (more than 400 char)
*& 2012.05.01 v1.1.1: Fix-Clipboard import
*&                    Fix-Add Compatibility with ECC5 & BW3.5
*&                    Fix-Compression mismatch between file and target
*&                    New-Add Gzip uncompression format
*& 2012.03.14 v1.1  : New-Auth management
*&                    Fix-Transfer mode
*&                    Fix-Open local file/folder
*&                    Fix-Move folder to root path
*& 2012.03.04 v1.0.2: New-Root path restriction
*&                    Fix-ECC6 ALV line selection bug
*& 2012.02.06 v1.0.1: Fix-Generic filetype naming
*& 2012.01.01 v1.0  : Initial release
*&---------------------------------------------------------------------*
* TODO ! manage multi selection file - at least in drag & drop

PROGRAM zal11.
TYPE-POOLS abap.

*######################################################################*
*
*                        CUSTOMIZATION SECTION
*
*######################################################################*

* To quickly customize this program, just set desired values in the
* following structure
DATA : BEGIN OF s_customize,                                "#EC NEEDED
* To restrict user acces, set the desired base path into root_path
* For example, root_path(600) TYPE c value '/usr/sap/PROD/data/'.
* Don't forget the final '/'
         root_path(600) TYPE c VALUE '', "\\FRDPGPSAP01\sapmnt\trans\

* Server name is defined as root name by default
* You can change the root name to be more explicit for the users
         root_name(20) TYPE c VALUE '',

* Automatic folder size. May take long time - not recommanded
* Set to abap_true to activate
         autodirsize(1) TYPE c VALUE space,

* Display shortcuts of usual server files (same as AL11)
* Generaly used only by system administrators
         logical_path(1) TYPE c VALUE abap_true,

* In server file details ALV, display total line at top
         total_on_top(1) TYPE c VALUE abap_true,

* If you dont consider download file as critical operation
* you could remove confirmation popup
         confirm_dl(1) TYPE c VALUE abap_true,

* You could define your authorization object to restrict
* function usage by user
* If you dont define auth object, all users will have access to
* all activated function
         auth_object(20) TYPE c VALUE '', "'ZAL11_AUTH',
         auth_id(10) TYPE c VALUE '', "'ACTION',

* Field defined by the program, do not change it
         root_path_len TYPE i VALUE 0,
       END OF s_customize,

* To disable globally a function, set default value to false
* In the authorization structure s_auth
* By default, all functions are activated
       BEGIN OF s_auth,                                     "#EC NEEDED
* Allow user to download file from server to local pc
* Required to open file on server
         download(1) TYPE c VALUE abap_true,
* Allow user to upload file from local pc to server
         upload(1) TYPE c VALUE abap_true,
* Allow user to overwrite existing file on server during an upload
         overwrite(1) TYPE c VALUE abap_true,
* Allow user to compress server file/folder
         zip(1) TYPE c VALUE abap_true,
* Allow user to uncompress server file
         unzip(1) TYPE c VALUE abap_true,
* Allow user to rename file on server
         rename_file(1) TYPE c VALUE abap_true,
* Allow user to rename folder on server
         rename_folder(1) TYPE c VALUE abap_true,
* Allow user to duplicate (copy) a file on the server
         duplicate_file(1) TYPE c VALUE abap_true,
* Allow user to duplicate (copy) folder on the server
         duplicate_folder(1) TYPE c VALUE abap_true,
* Allow user to move a file on the server
         move_file(1) TYPE c VALUE abap_true,
* Allow user to move a folder on the server
         move_folder(1) TYPE c VALUE abap_true,
* Allow user to delete a file on the server
         delete_file(1) TYPE c VALUE abap_true,
* Allow user to delete a folder on the server
         delete_folder(1) TYPE c VALUE abap_true,
* Allow user to create a folder on the server
         create_folder(1) TYPE c VALUE abap_true,
* Allow user to use shortcut (path) defined on the server
         shortcut(1) TYPE c VALUE abap_true,
* Allow user to create shortcuts on the server
* Shortcuts are shared for all users
         create_shortcut(1) TYPE c VALUE abap_true,
* Allow user to delete shortcuts on the server
* Shortcuts are shared for all users
         delete_shortcut(1) TYPE c VALUE abap_true,
* Allow user to get server path of a file into clipboard
         copy_path(1) TYPE c VALUE abap_true,
* Allow user to go to a path stored in the clipboard
         paste_path(1) TYPE c VALUE abap_true,
* Allow user to change attributes (chmod/attrib) of a file/folder
         chmod(1) TYPE c VALUE abap_true,
* Allow user to calculate folder size
         dirsize(1) TYPE c VALUE abap_true,
       END OF s_auth.

*######################################################################*
*
*                             DATA SECTION
*
*######################################################################*
CLASS lcl_application DEFINITION DEFERRED.
INTERFACE lif_server_command DEFERRED.
* Objects
DATA : o_container TYPE REF TO cl_gui_custom_container,
       o_splitter TYPE REF TO cl_gui_splitter_container,
       o_splitter_h TYPE REF TO cl_gui_splitter_container,
       o_splitter_l TYPE REF TO cl_gui_splitter_container,
       o_container_h TYPE REF TO cl_gui_container,
       o_container_l TYPE REF TO cl_gui_container,
       o_container_tree1 TYPE REF TO cl_gui_container,
       o_container_tree2 TYPE REF TO cl_gui_container,
       o_container_detail1 TYPE REF TO cl_gui_container,
       o_container_detail2 TYPE REF TO cl_gui_container,
       o_tree1 TYPE REF TO cl_gui_simple_tree,
       o_tree2 TYPE REF TO cl_gui_simple_tree,
       o_grid1 TYPE REF TO cl_gui_alv_grid,
       o_grid2 TYPE REF TO cl_gui_alv_grid,
       o_dragdrop_grid1 TYPE REF TO cl_dragdrop,
       o_dragdrop_grid2 TYPE REF TO cl_dragdrop,
       o_dragdrop_tree1 TYPE REF TO cl_dragdrop,
       o_dragdrop_tree2 TYPE REF TO cl_dragdrop,
       o_handle_event TYPE REF TO lcl_application,
       o_container_chmod TYPE REF TO cl_gui_custom_container,
       o_pbox_chmod TYPE REF TO cl_wdy_wb_property_box,
       o_server_command TYPE REF TO lif_server_command.

* List of local drives
DATA : BEGIN OF s_drive,
         drive(300) TYPE c,
         type(20) TYPE c,
         desc(300) TYPE c,
       END OF s_drive,
       t_drives LIKE STANDARD TABLE OF s_drive,

* Node structure
       BEGIN OF s_node.
        INCLUDE STRUCTURE mtreesnode.
DATA :   path(600) TYPE c,
         read(1) TYPE c,
         notreadable(1) TYPE c,
         texttosort TYPE mtreesnode-text,
       END OF s_node,

* Node tables
       t_nodes1 LIKE STANDARD TABLE OF s_node,
       t_nodes2 LIKE STANDARD TABLE OF s_node,

* Local Grid structure
       BEGIN OF s_detail1,
         icon(4) TYPE c,
         path(600) TYPE c,
         name(1024) TYPE c,
         dir TYPE i,
         filetype(20) TYPE c,
         len TYPE file_info-filelength,
         cdate TYPE dats,
         ctime TYPE tims,
         mdate TYPE dats,
         mtime TYPE tims,
         rdate TYPE dats,
         rtime TYPE tims,
         attrs(10) TYPE c,
         filetransfermode(3) TYPE c,
       END OF s_detail1,

* Remote grid structure
       BEGIN OF s_detail2,
         icon(4) TYPE c,
         path(600) TYPE c,
         name(1024) TYPE c,
         dir TYPE i,
         filetype(20) TYPE c,
         len(16) TYPE p,
         mdate TYPE dats,
         mtime TYPE tims,
         mode(9) TYPE c,
         attrs(10) TYPE c,
         owner(8) TYPE c, " owner of the entry.
         filetransfermode(3) TYPE c,
       END OF s_detail2,

* Grid tables
       t_details1 LIKE STANDARD TABLE OF s_detail1,
       t_details2 LIKE STANDARD TABLE OF s_detail2,

* Server shortcuts
       BEGIN OF s_shortcut,
         dirname TYPE user_dir-dirname,
         aliass TYPE user_dir-aliass,
         selkz TYPE c,
       END OF s_shortcut,
       t_shortcuts LIKE TABLE OF s_shortcut,

* Node key unique counter
       w_node1_count(12) TYPE n,
       w_node2_count(12) TYPE n,

* ALV config tables and structures
       t_fieldcat_grid1 TYPE lvc_t_fcat,
       t_sort_grid1 TYPE lvc_t_sort,
       s_layout_grid1 TYPE lvc_s_layo,
       t_fieldcat_grid2 TYPE lvc_t_fcat,
       t_sort_grid2 TYPE lvc_t_sort,
       s_layout_grid2 TYPE lvc_s_layo,

* Shared memory variable name
       w_shared_dir_local(30) TYPE c,
       w_shared_dir_remote(30) TYPE c,
       w_path LIKE s_node-path,

* CHMOD data
       w_chmod_to_set LIKE s_detail2-mode,
       w_owner_to_set LIKE s_detail2-owner,
       w_attrib_to_set LIKE s_detail2-attrs,

* Other global data
       w_okcode LIKE sy-ucomm,
       w_force_transfer_mode(10) TYPE c,
       w_server_name(20) TYPE c,
       w_handle_grid1 TYPE i,
       w_handle_grid2 TYPE i,
       w_handle_tree1 TYPE i,
       w_handle_tree2 TYPE i,

* List of distant server to display at start
       t_server_link TYPE TABLE OF rsparams.

* Constants
CONSTANTS : c_drivetype_hdd LIKE s_drive-type VALUE 'FIXED',
            c_drivetype_cd LIKE s_drive-type VALUE 'CDROM',
            c_drivetype_remote LIKE s_drive-type VALUE 'REMOTE',
            c_drivetype_usb LIKE s_drive-type VALUE 'REMOVEABLE',
            c_asc LIKE s_detail1-filetransfermode VALUE 'ASC',
            c_bin LIKE s_detail1-filetransfermode VALUE 'BIN',
            c_drivetypewin_usb LIKE s_drive-type VALUE '2',
            c_drivetypewin_hdd LIKE s_drive-type VALUE '3',
            c_drivetypewin_cd LIKE s_drive-type VALUE '5',
            c_drivetypewin_remote LIKE s_drive-type VALUE '4',
            c_wildcard(1) TYPE c VALUE '#',
            c_local_slash(1) TYPE c VALUE '\',
            c_goto_parent_dir(2) TYPE c VALUE '..',
            c_msg_error(1) TYPE c VALUE 'E',
            c_msg_success(1) TYPE c VALUE 'S',
            c_server_all TYPE user_dir-svrname VALUE 'all',
            c_open_no(1) TYPE c VALUE space,
            c_open_yes(1) TYPE c VALUE 'X',
            c_open_as(1) TYPE c VALUE 'A'.

*######################################################################*
*
*                             MACRO SECTION
*
*######################################################################*

*----------------------------------------------------------------------*
*       MACRO find_last_occurrence
*----------------------------------------------------------------------*
* Macro to get last occurrence
* With ECC6+ version, it just require FIND ALL OCCURRENCES but this
* instruction does not exist in ECC5 or older SAP version.
* So i define a macro to easily manage the switch
* If you are in ECC5- sap version, just comment the fist line and
* uncomment the other lines of this macro
*----------------------------------------------------------------------*
DEFINE find_last_occurrence.
  find all occurrences of &1 in &2 match offset &3.
*  replace all occurrences of &1 in &2 with &1 replacement offset &3.
END-OF-DEFINITION. "find_last_occurrence

*######################################################################*
*
*                             CLASS SECTION
*
*######################################################################*

*----------------------------------------------------------------------*
*       INTERFACE lif_server_command
*----------------------------------------------------------------------*
*       Define all server dependant command / constants
*----------------------------------------------------------------------*
INTERFACE lif_server_command.
  DATA : slash(1) TYPE c,
         last_command(1000) TYPE c,
         attrib_mode TYPE i,
         root_not_readable(1) TYPE c.
  CONSTANTS : c_copymode_file TYPE i VALUE 1,
              c_copymode_folder TYPE i VALUE 2,
              c_attrmode_none TYPE i VALUE 0,
              c_attrmode_chmod TYPE i VALUE 1,
              c_attrmode_attrib TYPE i VALUE 2.
* Method to create folder
  METHODS : create_folder IMPORTING i_newfolder TYPE string
                          EXPORTING e_subrc  TYPE i,
* Method to copy file or folder
            copy          IMPORTING i_source TYPE string
                                    i_target TYPE string
                                    i_mode   TYPE i
                          EXPORTING e_subrc  TYPE i,
* Method to delete file or folder and there content
            delete        IMPORTING i_source TYPE string
                                    i_mode   TYPE i
                          EXPORTING e_subrc  TYPE i,
* Method to move file or folder
            move          IMPORTING i_source TYPE string
                                    i_target TYPE string
                          EXPORTING e_subrc  TYPE i,
* Method to rename file or folder
            rename        IMPORTING i_source TYPE string
                                    i_target TYPE string
                          EXPORTING e_subrc  TYPE i,
* Method to change attributes for file or folder
            change_attrib IMPORTING i_file   TYPE string
                                    i_params TYPE string
                          EXPORTING e_subrc  TYPE i,
* Method to compress file or folder
* i_file parameter must be unprotected
            compress      IMPORTING i_file   TYPE string
                          EXPORTING e_subrc  TYPE i,
* Method to uncompress file
* i_file & i_path parameters must be unprotected
            uncompress    IMPORTING i_file   TYPE string
                                    i_path   TYPE string
                          EXPORTING e_subrc  TYPE i,
* Method to get attribute of a file or folder
            get_attrib    IMPORTING i_file   TYPE string
                          EXPORTING e_attrib TYPE string,
* Method to put filename inside " " before queriing server
            file_protect  IMPORTING i_file   TYPE string
                          RETURNING value(e_file) TYPE string,
            drive_list    EXPORTING e_drive_table LIKE t_drives,
* Commit server after action (wait 1 seconds until find a better way)
            commit,
            get_folder_size IMPORTING i_file TYPE string
                            RETURNING value(e_size) LIKE s_detail2-len.

ENDINTERFACE.                    "lif_server_command

*----------------------------------------------------------------------*
*       CLASS lcl_aix_server DEFINITION
*----------------------------------------------------------------------*
*       Apply interface lif_server_command to AIX server
*----------------------------------------------------------------------*
CLASS lcl_aix_server DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES lif_server_command DATA VALUES slash = '/'
               attrib_mode = lif_server_command=>c_attrmode_chmod
               root_not_readable = space.

    ALIASES: create_folder FOR lif_server_command~create_folder,
             copy FOR lif_server_command~copy,
             delete FOR lif_server_command~delete,
             move  FOR lif_server_command~move,
             rename FOR lif_server_command~rename,
             change_attrib FOR lif_server_command~change_attrib,
             compress FOR lif_server_command~compress,
             uncompress FOR lif_server_command~uncompress,
             get_attrib FOR lif_server_command~get_attrib,
             file_protect FOR lif_server_command~file_protect,
             drive_list FOR lif_server_command~drive_list,
             commit FOR lif_server_command~commit,
             get_folder_size FOR lif_server_command~get_folder_size,
             slash FOR lif_server_command~slash,
             last_command FOR lif_server_command~last_command,
             root_not_readable FOR lif_server_command~root_not_readable.

ENDCLASS.                    "lcl_aix_server DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_aix_server IMPLEMENTATION
*----------------------------------------------------------------------*
*       Define all server AIX dependant command / constants
*----------------------------------------------------------------------*
CLASS lcl_aix_server  IMPLEMENTATION.
  METHOD create_folder.
    CONCATENATE 'mkdir' i_newfolder INTO last_command       "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "create_folder

  METHOD copy.
    CONCATENATE 'cp -r' i_source i_target INTO last_command "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "copy

  METHOD delete.
    CASE i_mode.
      WHEN lif_server_command~c_copymode_file.
        CONCATENATE 'rm' i_source INTO last_command         "#EC NOTEXT
                    SEPARATED BY space.
      WHEN lif_server_command~c_copymode_folder.
        CONCATENATE 'rm -R' i_source INTO last_command      "#EC NOTEXT
                    SEPARATED BY space.
    ENDCASE.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "delete

  METHOD move.
    CONCATENATE 'mv' i_source i_target INTO last_command    "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "move

  METHOD rename.
    CONCATENATE 'mv' i_source i_target INTO last_command    "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "rename

  METHOD change_attrib.
    CONCATENATE 'chmod' i_params i_file INTO last_command   "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "chmod

  METHOD compress.
    DATA : lw_file_to TYPE string,
           lw_file_from TYPE string.

* Delete old .bz2 file (otherwelse bzip cannot create the new bz2 file)
    CONCATENATE i_file '.tar.bz2' INTO lw_file_to.
    lw_file_to = file_protect( lw_file_to ).

    CONCATENATE 'rm' lw_file_to INTO last_command           "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    commit( ).

* duplicate current file into tar format
    lw_file_from = file_protect( i_file ).
    CONCATENATE i_file '.tar' INTO lw_file_to.              "#EC NOTEXT
    lw_file_to = file_protect( lw_file_to ).
    CONCATENATE 'tar cf' lw_file_to lw_file_from            "#EC NOTEXT
                INTO last_command SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    commit( ).

* replace the tar file by tar.bz2 compressed file
    CONCATENATE 'bzip2 -9' lw_file_to INTO last_command     "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "compress

  METHOD uncompress.
    DATA : lw_pos TYPE i,
           lw_extension TYPE string,
           lw_file TYPE string,
           lw_path TYPE string.
    CLEAR e_subrc.

* Find type of compression to uncompress
    find_last_occurrence '.'  i_file lw_pos.
    IF sy-subrc NE 0.
      e_subrc = 1. "no extension
      RETURN.
    ENDIF.
    lw_extension = i_file+lw_pos.
    TRANSLATE lw_extension TO LOWER CASE.

    CONCATENATE i_path i_file INTO lw_file.
    lw_file = file_protect( lw_file ).
    lw_path = file_protect( i_path ).

* bzip compression
    IF lw_extension = '.bz2'.
* Server command to unbzip2 file
      CONCATENATE 'bunzip2' lw_file INTO last_command       "#EC NOTEXT
                  SEPARATED BY space.
      CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
      e_subrc = sy-subrc.
* when file is unbziped, the original file is replaced by the extracted
* one
* Search new extension to chain uncompression (with tar for example)
      lw_file = i_file(lw_pos).
      find_last_occurrence '.' lw_file lw_pos.
      IF sy-subrc = 0.
        lw_extension = lw_file+lw_pos.
        TRANSLATE lw_extension TO LOWER CASE.
        CONCATENATE i_path lw_file INTO lw_file.
        lw_file = file_protect( lw_file ).
        commit( ).
      ELSE.
        CLEAR lw_extension.
      ENDIF.
    ENDIF.

* gzip compression
    IF lw_extension = '.gz'.
* Server command to ungzip2 file
      CONCATENATE 'gunzip' lw_file INTO last_command        "#EC NOTEXT
                  SEPARATED BY space.
      CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
      e_subrc = sy-subrc.
* when file is ungziped, the original file is replaced by the extracted
* one
* Search new extension to chain uncompression (with tar for example)
      lw_file = i_file(lw_pos).
      find_last_occurrence '.' lw_file lw_pos.
      IF sy-subrc = 0.
        lw_extension = lw_file+lw_pos.
        TRANSLATE lw_extension TO LOWER CASE.
        CONCATENATE i_path lw_file INTO lw_file.
        lw_file = file_protect( lw_file ).
        commit( ).
      ELSE.
        CLEAR lw_extension.
      ENDIF.
    ENDIF.

* tar compression
    IF lw_extension = '.tar'.
      CONCATENATE 'tar xf' lw_file INTO last_command        "#EC NOTEXT
                  SEPARATED BY space.
      CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
      e_subrc = sy-subrc.
    ENDIF.

* zip compression
    IF lw_extension = '.zip'.
      CONCATENATE 'unzip' lw_file '-d' lw_path              "#EC NOTEXT
                  INTO last_command SEPARATED BY space.
      CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
      e_subrc = sy-subrc.
    ENDIF.
  ENDMETHOD.                    "uncompress

  METHOD get_attrib.
    CLEAR e_attrib.
  ENDMETHOD.                    "get_attrib

  METHOD drive_list.
    REFRESH e_drive_table.
  ENDMETHOD.                    "drive_list

  METHOD file_protect.
    IF i_file IS NOT INITIAL AND i_file(1) NE '"'.
      CONCATENATE '"' i_file '"' INTO e_file.
    ELSE.
      e_file = i_file.
    ENDIF.
  ENDMETHOD.                    "file_protect

  METHOD commit.
* If application server is too fast, file server is not updated
* before querriing. Wait 1 second after server action
    WAIT UP TO 1 SECONDS.
  ENDMETHOD.                    "commit

  METHOD get_folder_size.
    DATA : lw_line(150) TYPE c,
           lt_tab LIKE TABLE OF lw_line,
           lw_size TYPE string,
           lw_dummy TYPE string.                            "#EC NEEDED

    CLEAR e_size.
* Get size in ko
    CONCATENATE 'du -sk' i_file INTO last_command           "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command
                  ID 'TAB'     FIELD lt_tab.
    READ TABLE lt_tab INTO lw_line INDEX 1.
* Return size in octets
    IF sy-subrc = 0.
      SPLIT lw_line AT cl_abap_char_utilities=>horizontal_tab
            INTO lw_size lw_dummy.
      e_size = lw_size * 1000.
    ENDIF.
  ENDMETHOD.                    "get_folder_size
ENDCLASS. "lcl_aix_server

*----------------------------------------------------------------------*
*       CLASS lcl_windows_server DEFINITION
*----------------------------------------------------------------------*
*       Apply interface lif_server_command to Windows server
*----------------------------------------------------------------------*
CLASS lcl_windows_server DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES lif_server_command DATA VALUES slash = '\'
               attrib_mode = lif_server_command=>c_attrmode_attrib
               root_not_readable = abap_true.
    ALIASES: create_folder FOR lif_server_command~create_folder,
             copy FOR lif_server_command~copy,
             delete FOR lif_server_command~delete,
             move  FOR lif_server_command~move,
             rename FOR lif_server_command~rename,
             change_attrib FOR lif_server_command~change_attrib,
             compress FOR lif_server_command~compress,
             uncompress FOR lif_server_command~uncompress,
             get_attrib FOR lif_server_command~get_attrib,
             file_protect FOR lif_server_command~file_protect,
             drive_list FOR lif_server_command~drive_list,
             commit FOR lif_server_command~commit,
             get_folder_size FOR lif_server_command~get_folder_size,
             slash FOR lif_server_command~slash,
             last_command FOR lif_server_command~last_command,
             root_not_readable FOR lif_server_command~root_not_readable.
ENDCLASS.                    "lcl_windows_server DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_windows_server IMPLEMENTATION
*----------------------------------------------------------------------*
*       Define all server Windows dependant command / constants
*----------------------------------------------------------------------*
CLASS lcl_windows_server  IMPLEMENTATION.
  METHOD create_folder.
    CONCATENATE 'mkdir' i_newfolder INTO last_command       "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "create_folder

  METHOD copy.
    CASE i_mode.
      WHEN lif_server_command~c_copymode_file.
        CONCATENATE 'copy' i_source i_target                "#EC NOTEXT
                    INTO last_command SEPARATED BY space.
      WHEN lif_server_command~c_copymode_folder.
        CONCATENATE 'xcopy /i /e' i_source i_target         "#EC NOTEXT
                    INTO last_command SEPARATED BY space.
    ENDCASE.

    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "copy

  METHOD delete.
    CASE i_mode.
      WHEN lif_server_command~c_copymode_file.
        CONCATENATE 'del' i_source INTO last_command        "#EC NOTEXT
                    SEPARATED BY space.
      WHEN lif_server_command~c_copymode_folder.
* to delete folder, need to delete all files inside before
        CONCATENATE 'del /q/s' i_source INTO last_command   "#EC NOTEXT
                    SEPARATED BY space.
        CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
        commit( ).
        CONCATENATE 'rmdir' i_source INTO last_command      "#EC NOTEXT
                    SEPARATED BY space.
    ENDCASE.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "delete

  METHOD move.
    CONCATENATE 'move' i_source i_target INTO last_command  "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "move

  METHOD rename.
    CONCATENATE 'move' i_source i_target INTO last_command  "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "rename

  METHOD change_attrib.
    CONCATENATE 'attrib' i_params i_file INTO last_command  "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command.
    e_subrc = sy-subrc.
  ENDMETHOD.                    "change_attrib

  METHOD compress.
* Use ABAP zip tool for compression
* Currently designed only for single file
* Dont work for folder !
    DATA: lt_tab            TYPE swxmlcont,
          ls_tab            TYPE x255.

    DATA: lw_zip_content TYPE xstring,
          lw_zip_file(255) TYPE c,
          lw_content TYPE xstring,
          lo_zip TYPE REF TO cl_abap_zip.
    CLEAR e_subrc.

    CREATE OBJECT lo_zip.

* Read the data as a string
    CLEAR lw_content .
    OPEN DATASET i_file FOR INPUT IN BINARY MODE.
    READ DATASET i_file INTO lw_content.
    CLOSE DATASET i_file.

*Add a File to a Zip Folder
    lo_zip->add( name    = i_file
                 content = lw_content ).

    CLEAR lw_content.

*Create a Zip File
    lw_zip_content = lo_zip->save( ).

* Convert the xstring content to binary
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lw_zip_content
      TABLES
        binary_tab = lt_tab.

*Download file to the application server
    CONCATENATE i_file '.zip' INTO lw_zip_file.             "#EC NOTEXT
    OPEN DATASET lw_zip_file FOR OUTPUT IN BINARY MODE.
    LOOP AT lt_tab INTO ls_tab.
      TRANSFER ls_tab TO lw_zip_file.
    ENDLOOP.
    CLOSE DATASET lw_zip_file.
  ENDMETHOD.                    "compress

  METHOD uncompress.
    CLEAR e_subrc.
    MESSAGE 'Uncompression not yet managed'(e26) TYPE c_msg_success
            DISPLAY LIKE c_msg_error. "TODO
  ENDMETHOD.                    "uncompress

  METHOD get_attrib.
    DATA: ls_result  TYPE char255,
          lt_result  TYPE STANDARD TABLE OF char255.
    CLEAR e_attrib.

    CONCATENATE 'attrib' i_file INTO last_command           "#EC NOTEXT
                SEPARATED BY space.
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command
                  ID 'TAB'     FIELD lt_result.
    READ TABLE lt_result INTO ls_result INDEX 1.
    IF sy-subrc = 0.
      e_attrib = ls_result(10).
      CONDENSE e_attrib NO-GAPS.
    ENDIF.
  ENDMETHOD.                    "get_attrib

  METHOD file_protect.
    IF i_file IS NOT INITIAL AND i_file(1) NE '"'.
      CONCATENATE '"' i_file '"' INTO e_file.
    ELSE.
      e_file = i_file.
    ENDIF.
  ENDMETHOD.                    "file_protect
  METHOD drive_list.
    DATA : lw_line(150) TYPE c,
           lt_tab LIKE TABLE OF lw_line,
           ls_drive LIKE LINE OF e_drive_table.

    REFRESH e_drive_table.
    last_command = 'wmic logicaldisk get Name,DriveType,VolumeName'. "#EC NOTEXT
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command
               ID 'TAB'     FIELD lt_tab.
* Delete header results
    DELETE lt_tab INDEX 1.
* Fill drive table
    LOOP AT lt_tab INTO lw_line.
      CLEAR ls_drive.
      ls_drive-drive = lw_line+11(2).
      ls_drive-type = lw_line(1).
      ls_drive-desc = lw_line+17(12).
* set default text if no label for the drive
      IF ls_drive-desc IS INITIAL.
        CASE ls_drive-type.
          WHEN c_drivetypewin_usb.
            ls_drive-desc = 'Removable Drive (#:)'(c05).
          WHEN c_drivetypewin_hdd.
            ls_drive-desc = 'Local Disk (#:)'(c02).
          WHEN c_drivetypewin_cd.
            ls_drive-desc = 'CDROM Drive (#:)'(c03).
          WHEN c_drivetypewin_remote.
            ls_drive-desc = 'Remote Drive (#:)'(c04).
          WHEN OTHERS.
            ls_drive-desc = 'Unknown (#:)'(c06).
        ENDCASE.
      ELSE.
        CONCATENATE ls_drive-desc '(#:)' INTO ls_drive-desc "#EC NOTEXT
                    SEPARATED BY space.
      ENDIF.
      REPLACE FIRST OCCURRENCE OF c_wildcard IN ls_drive-desc
              WITH ls_drive-drive(1).
      IF ls_drive-type CO '1234567 '. "type of drives managed
        APPEND ls_drive TO e_drive_table.
      ENDIF.
    ENDLOOP.

** If not working for your windows server, you could scan each drive 1 by 1
*    DATA : lw_abcde TYPE syabcde,
*           lw_drivetemplate TYPE char3 VALUE ' :\',
*           lw_errno(3) TYPE c,
*           lw_errmsg(40) TYPE c.
*    DATA : lt_table type table of spflist.
*    REFRESH e_drive_table.
** Get all letters
*    lw_abcde = sy-abcde.
*    CONDENSE lw_abcde NO-GAPS.
** Check if each letter is mounted
*    WHILE lw_abcde IS NOT INITIAL.
*      lw_drivetemplate(1) = lw_abcde(1).
*      SHIFT lw_abcde BY 1 PLACES.
*      REFRESH lt_table.
** Read the folder
*      CALL 'ALERTS'  ID 'ADMODE'       FIELD 20
*                     ID 'OPCODE'       FIELD 14 "read directory
*                     ID 'FILE_NAME'    FIELD lw_drivetemplate
*                     ID 'DIR_TBL'      FIELD lt_table.
*
*      IF NOT lt_table[] IS INITIAL.
*        ls_drive-drive = lw_drivetemplate(2).
*        ls_drive-desc = lw_drivetemplate(2).
*        APPEND ls_drive TO e_drive_table.
*      ENDIF.
*    ENDWHILE.
  ENDMETHOD.                    "drive_list

  METHOD commit.
    WAIT UP TO 1 SECONDS.
  ENDMETHOD.                    "commit

  METHOD get_folder_size.
    CLEAR e_size.
    DATA : lw_line(150) TYPE c,
           lt_tab LIKE TABLE OF lw_line,
           lw_line_count TYPE i.

    CONCATENATE 'dir /s /-C' i_file INTO last_command SEPARATED BY space. "#EC NOTEXT
    CALL 'SYSTEM' ID 'COMMAND' FIELD last_command
               ID 'TAB'     FIELD lt_tab.

* Take sum line in the end of the list
    DESCRIBE TABLE lt_tab LINES lw_line_count.
    lw_line_count = lw_line_count - 1.
    IF lw_line_count LT 1.
      RETURN.
    ENDIF.
    READ TABLE lt_tab INTO lw_line INDEX lw_line_count.

* Search sum in the line
    SPLIT lw_line AT space INTO TABLE lt_tab.
    DESCRIBE TABLE lt_tab LINES lw_line_count.
    LOOP AT lt_tab INTO lw_line.
* delete empty lines
      CHECK lw_line IS INITIAL.
      DELETE lt_tab.
    ENDLOOP.

* Third line contain the size in byte
    READ TABLE lt_tab INTO lw_line INDEX 3.
    IF lw_line CO ' 0123456789'.
      e_size = lw_line.
    ENDIF.

** Delete 2 firsts words (number of files counted)
** and last word (byte)
*    DELETE lt_tab FROM 1 TO 2.
** Delete last word (byte)
*    DESCRIBE TABLE lt_tab LINES lw_line_count.
*    DELETE lt_tab FROM lw_line_count.
*    CLEAR lw_size.
*    LOOP AT lt_tab INTO lw_line.
*      IF NOT lw_line CO '0123456789'.
*        REPLACE ALL OCCURRENCES OF REGEX '[^0-9]' IN lw_line WITH ''.
*      ENDIF.
*      CONCATENATE lw_size lw_line INTO lw_size.
*    ENDLOOP.
*
*    e_size = lw_size.

  ENDMETHOD.                    "get_folder_size
ENDCLASS. "lcl_windows_server

*----------------------------------------------------------------------*
*       CLASS lcl_application DEFINITION
*----------------------------------------------------------------------*
*       Class to handle application events
*----------------------------------------------------------------------*
CLASS lcl_application DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
* Handle clic on local tree node (folder) to display the content in alv
      handle_select
        FOR EVENT selection_changed
        OF cl_gui_simple_tree
        IMPORTING node_key,
* Handle clic on remote tree node (folder) to display the content in alv
      handle_select_remote
        FOR EVENT selection_changed
        OF cl_gui_simple_tree
        IMPORTING node_key,
* Handle doubleclic on local alv line to navigate
      handle_grid_double_click
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING es_row_no,
* Handle doubleclic on remote alv line to navigate
      handle_grid_double_click_remot
        FOR EVENT double_click
        OF cl_gui_alv_grid
        IMPORTING es_row_no,
* Handle call of local context menu to display specific menus
      handle_grid_context_local
        FOR EVENT context_menu_request
        OF cl_gui_alv_grid
        IMPORTING e_object,
* Handle call of remote context menu to display specific menus
      handle_grid_context
        FOR EVENT context_menu_request
        OF cl_gui_alv_grid
        IMPORTING e_object,
* Handle remote grid toolbar display to add specific button
      handle_toolbar
        FOR EVENT toolbar
        OF cl_gui_alv_grid
        IMPORTING e_object,
* Handle menu button click to display specific menus
      handle_menu_button
        FOR EVENT menu_button
        OF cl_gui_alv_grid
        IMPORTING e_object e_ucomm,
* Handle grid user command to manage specific fcode (menus & toolbar)
      handle_user_command
        FOR EVENT user_command
        OF cl_gui_alv_grid
        IMPORTING e_ucomm,
* Handle drag from grid (local & remote)
      handle_grid_drag
        FOR EVENT ondrag
        OF cl_gui_alv_grid
        IMPORTING e_row e_dragdropobj,
* Handle drop into local grid
      handle_local_grid_drop
        FOR EVENT ondrop
        OF cl_gui_alv_grid
        IMPORTING e_row e_dragdropobj,
* Handle drop into remote grid
      handle_remote_grid_drop
        FOR EVENT ondrop
        OF cl_gui_alv_grid
        IMPORTING e_row e_dragdropobj,
* Handle drop into local tree
      handle_local_tree_drop
        FOR EVENT on_drop
        OF cl_gui_simple_tree
        IMPORTING node_key drag_drop_object,
* Handle drop into remote tree
      handle_remote_tree_drop
        FOR EVENT on_drop
        OF cl_gui_simple_tree
        IMPORTING node_key drag_drop_object.

* Private data for drag&drop
  PRIVATE SECTION.
    DATA : lw_drag_handle TYPE i,
           lw_drag_rowid TYPE i.
ENDCLASS.                    "lcl_application DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*----------------------------------------------------------------------*
*       Class to handle application events                             *
*----------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.
*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_local_tree_drag
*&---------------------------------------------------------------------*
*       Handle drop to local tree
*----------------------------------------------------------------------*
  METHOD handle_local_tree_drop.
    DATA : ls_detail2 LIKE s_detail2,
           ls_node LIKE s_node.

* if drag from grid 2 => download
    IF lw_drag_handle = w_handle_grid2.
* read drag
      READ TABLE t_details2 INTO ls_detail2 INDEX lw_drag_rowid.
      IF ls_detail2-dir = 1 OR sy-subrc NE 0.
        MESSAGE 'Please choose a remote file to download'(e01)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        CALL METHOD drag_drop_object->abort.
        RETURN.
      ENDIF.

* read drop
      READ TABLE t_nodes1 INTO ls_node WITH KEY node_key = node_key.
      IF sy-subrc NE 0.
        MESSAGE 'Cannot find target...'(e02) TYPE c_msg_success
                 DISPLAY LIKE c_msg_error.
        CALL METHOD drag_drop_object->abort.
        RETURN.
      ENDIF.

      PERFORM save_remote_to_local USING ls_detail2-path
                                         ls_detail2-name
                                         ls_node-path
                                         ls_detail2-name
                                         ls_detail2-filetransfermode
                                         c_open_no.

* if drop is folder, open tree on this folder
      CALL METHOD o_tree1->set_selected_node
        EXPORTING
          node_key = node_key.
      PERFORM change_local_folder USING node_key.

* if drag from grid 1 => move/copy file
*      ELSE.
* TODO
    ENDIF.
  ENDMETHOD. " handle_local_tree_drop

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_remote_tree_drag
*&---------------------------------------------------------------------*
*       Handle drop to remote tree
*----------------------------------------------------------------------*
  METHOD handle_remote_tree_drop.
    DATA : ls_node LIKE s_node,
           ls_detail1 LIKE s_detail1,
           ls_detail2 LIKE s_detail2,
           lw_name LIKE s_detail2-name.

* Upload
    IF drag_drop_object->dragsourcectrl = o_grid1.
* read drag
      READ TABLE t_details1 INTO ls_detail1 INDEX lw_drag_rowid.
      IF ls_detail1-dir = 1 OR sy-subrc NE 0.
        MESSAGE 'Please choose a local file to upload'(e03)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        CALL METHOD drag_drop_object->abort.
        RETURN.
      ENDIF.
* read drop
      READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = node_key.
      IF sy-subrc NE 0 OR ls_node-notreadable NE space.
        MESSAGE 'Cannot find target...'(e02) TYPE c_msg_success
                 DISPLAY LIKE c_msg_error.
        CALL METHOD drag_drop_object->abort.
        RETURN.
      ENDIF.
* Upload file
      PERFORM save_local_to_remote USING ls_detail1-path
                                         ls_detail1-name
                                         ls_node-path
                                         ls_detail1-name
                                         ls_detail1-filetransfermode.
      CALL METHOD o_tree2->set_selected_node
        EXPORTING
          node_key = node_key.
      PERFORM change_remote_folder USING node_key.

* Move/copy on server
    ELSEIF drag_drop_object->dragsourcectrl = o_grid2.
* read drag
      READ TABLE t_details2 INTO ls_detail2 INDEX lw_drag_rowid.
      IF sy-subrc NE 0 OR ls_detail2-name = c_goto_parent_dir.
        MESSAGE 'Please choose a local file/folder to upload'(e20)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        CALL METHOD drag_drop_object->abort.
        RETURN.
      ENDIF.

* read drop
      READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = node_key.
      IF sy-subrc NE 0 OR ls_node-notreadable NE space.
        MESSAGE 'Cannot find target...'(e02) TYPE c_msg_success
                 DISPLAY LIKE c_msg_error.
        CALL METHOD drag_drop_object->abort.
        RETURN.
      ENDIF.

* source folder = target folder => duplicate item
      IF ls_node-path = ls_detail2-path.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM duplicate_item USING lw_name ls_detail2-dir.
* if duplicate a folder, refresh tree
        IF ls_detail2-dir = 1.
          PERFORM refresh_tree2 USING ls_node.
* if duplicate a file, refresh grid only
        ELSE.
          PERFORM get_remote_folder_detail USING ls_detail2-path.
          PERFORM refresh_grid_display USING 2.
        ENDIF.

* source and target are different => copy/move
      ELSE.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM copy_item USING lw_name
                                ls_node-path
                                drag_drop_object->effect
                                ls_detail2-dir.
* if move a folder, refresh tree from and tree to
        IF ls_detail2-dir = 1.
          READ TABLE t_nodes2 INTO ls_node WITH KEY path = ls_detail2-path.
          PERFORM refresh_tree2 USING ls_node.
          READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = node_key.
          IF sy-subrc = 0.
            PERFORM refresh_tree2 USING ls_node.
          ENDIF.
* if move a file, refresh grid only
        ELSE.
          PERFORM get_remote_folder_detail USING ls_detail2-path.
          PERFORM refresh_grid_display USING 2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD. "handle_remote_tree_drop

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_grid_drag
*&---------------------------------------------------------------------*
*       Handle drag from grid (local & remote)
*----------------------------------------------------------------------*
  METHOD handle_grid_drag.
* Check which grid is dragged
    IF e_dragdropobj->dragsourcectrl = o_grid1.
      lw_drag_handle = w_handle_grid1.
      e_dragdropobj->object = o_grid1.
    ENDIF.
    IF e_dragdropobj->dragsourcectrl = o_grid2.
      lw_drag_handle = w_handle_grid2.
      e_dragdropobj->object = o_grid2.
    ENDIF.
* Keep drag row id to use at drop event
    lw_drag_rowid = e_row-index.
  ENDMETHOD.                    "handle_grid_drag

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_remote_grid_drop
*&---------------------------------------------------------------------*
*       Handle drop into remote grid
*----------------------------------------------------------------------*
  METHOD handle_remote_grid_drop.
    DATA : ls_detail1 LIKE s_detail1,
           ls_detail2 LIKE s_detail2,
           ls_detail2_bis LIKE s_detail2,
           ls_node LIKE s_node,
           lw_index TYPE i,
           lw_name LIKE s_detail1-path.

* if drag from grid 1 => upload
    IF lw_drag_handle = w_handle_grid1.
* read drag
      READ TABLE t_details1 INTO ls_detail1 INDEX lw_drag_rowid.
      IF ls_detail1-dir = 1 OR sy-subrc NE 0.
        MESSAGE 'Please choose a local file to upload'(e03)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        CALL METHOD e_dragdropobj->abort.
        RETURN.
      ENDIF.
* read drop (or first line in case of drop in ctrl)
      IF e_row-index IS INITIAL.
        READ TABLE t_details2 INTO ls_detail2 INDEX 1.
      ELSE.
        READ TABLE t_details2 INTO ls_detail2 INDEX e_row-index.
      ENDIF.
      IF sy-subrc NE 0.
        MESSAGE 'Cannot find target...'(e02) TYPE c_msg_success
                 DISPLAY LIKE c_msg_error.
        CALL METHOD e_dragdropobj->abort.
        RETURN.
      ENDIF.
* drop on a folder, copy into this folder (and open it)
      IF ls_detail2-dir = 1 AND ls_detail2-name NE c_goto_parent_dir.
        CONCATENATE ls_detail2-path ls_detail2-name o_server_command->slash
                    INTO ls_detail2-path.
      ENDIF.
      PERFORM save_local_to_remote USING ls_detail1-path
                                         ls_detail1-name
                                         ls_detail2-path
                                         ls_detail1-name
                                         ls_detail1-filetransfermode.
* if drop is folder, open tree on this folder
      IF ls_detail2-dir = 1 AND ls_detail2-name NE c_goto_parent_dir.
        READ TABLE t_nodes2 INTO s_node
                   WITH KEY path = ls_detail2-path.
        CALL METHOD o_tree2->set_selected_node
          EXPORTING
            node_key = s_node-node_key.
        PERFORM change_remote_folder USING s_node-node_key.
      ELSE.
* if drop is file or contaner, refresh grid
        PERFORM get_remote_folder_detail USING ls_detail2-path.
        PERFORM refresh_grid_display USING 2.
      ENDIF.

* if drag from grid 2 => move/copy file
    ELSE.
* read drag
      READ TABLE t_details2 INTO ls_detail2 INDEX lw_drag_rowid.
      IF sy-subrc NE 0 OR ls_detail2-name = c_goto_parent_dir.
        MESSAGE 'Please choose a local file/folder to upload'(e20)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        CALL METHOD e_dragdropobj->abort.
        RETURN.
      ENDIF.
* read drop (or first line in case of drop in ctrl)
      IF e_row-index IS INITIAL.
        READ TABLE t_details2 INTO ls_detail2_bis INDEX 1.
      ELSE.
        READ TABLE t_details2 INTO ls_detail2_bis INDEX e_row-index.
      ENDIF.
      IF sy-subrc NE 0.
        MESSAGE 'Cannot find target...'(e02) TYPE c_msg_success
                 DISPLAY LIKE c_msg_error.
        CALL METHOD e_dragdropobj->abort.
        RETURN.
      ENDIF.
* '..' choosen, find parent path
      IF ls_detail2_bis-name = c_goto_parent_dir
      AND NOT e_row-index IS INITIAL.
        lw_index = strlen( ls_detail2_bis-path ).
        lw_index = lw_index - 1.
        IF ls_detail2_bis-path+lw_index(1) = o_server_command->slash.
          ls_detail2_bis-path = ls_detail2_bis-path(lw_index).
        ENDIF.
        find_last_occurrence o_server_command->slash ls_detail2_bis-path
                             lw_index.
        IF sy-subrc NE 0 OR
        ( lw_index = 0 AND ls_detail2_bis-path(1) NE o_server_command->slash ).
          MESSAGE 'Error when calculate target...'(e04)
                  TYPE c_msg_success DISPLAY LIKE c_msg_error.
          CALL METHOD e_dragdropobj->abort.
          RETURN.
        ENDIF.
        lw_index = lw_index + 1.
        ls_detail2_bis-path = ls_detail2_bis-path(lw_index).

* folder chooser,
      ELSEIF ls_detail2_bis-dir = 1
      AND ls_detail2_bis-name NE c_goto_parent_dir.
        CONCATENATE ls_detail2_bis-path ls_detail2_bis-name
                    o_server_command->slash INTO ls_detail2_bis-path.
      ENDIF.

* source folder = target folder => duplicate item
      IF ls_detail2_bis-path = ls_detail2-path.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM duplicate_item USING lw_name ls_detail2-dir.
* if duplicate a folder, refresh tree
        IF ls_detail2-dir = 1.
          READ TABLE t_nodes2 INTO ls_node
                     WITH KEY path = ls_detail2-path.
          PERFORM refresh_tree2 USING ls_node.
* if duplicate a file, refresh grid only
        ELSE.
          PERFORM get_remote_folder_detail USING ls_detail2-path.
          PERFORM refresh_grid_display USING 2.
        ENDIF.

* source and target are different => copy/move
      ELSE.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM copy_item USING lw_name
                                ls_detail2_bis-path
                                e_dragdropobj->effect
                                ls_detail2-dir.
* if move a folder, refresh tree
        IF ls_detail2-dir = 1.
* special case of moving a folder to parent folder need to refresh
* parent tree node
          IF ls_detail2_bis-name = c_goto_parent_dir
          AND NOT e_row-index IS INITIAL.
            READ TABLE t_nodes2 INTO ls_node
                       WITH KEY path = ls_detail2_bis-path.
          ELSE.
            READ TABLE t_nodes2 INTO ls_node
                       WITH KEY path = ls_detail2-path.
          ENDIF.
          PERFORM refresh_tree2 USING ls_node.
* if move a file, refresh grid only
        ELSE.
          PERFORM get_remote_folder_detail USING ls_detail2-path.
          PERFORM refresh_grid_display USING 2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "handle_remote_grid_drop

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_local_grid_drop
*&---------------------------------------------------------------------*
*       Handle drop into local grid
*----------------------------------------------------------------------*
  METHOD handle_local_grid_drop.
    DATA : ls_detail1 LIKE s_detail1,
           ls_detail2 LIKE s_detail2.

* if drag from grid 2 => download
    IF lw_drag_handle = w_handle_grid2.
* read drag
      READ TABLE t_details2 INTO ls_detail2 INDEX lw_drag_rowid.
      IF ls_detail2-dir = 1 OR sy-subrc NE 0.
        MESSAGE 'Please choose a remote file to download'(e01)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        CALL METHOD e_dragdropobj->abort.
        RETURN.
      ENDIF.

* read drop (or first line in case of drop in ctrl)
      IF e_row-index IS INITIAL.
        READ TABLE t_details1 INTO ls_detail1 INDEX 1.
      ELSE.
        READ TABLE t_details1 INTO ls_detail1 INDEX e_row-index.
      ENDIF.
      IF sy-subrc NE 0.
        MESSAGE 'Cannot find target...'(e02) TYPE c_msg_success
                 DISPLAY LIKE c_msg_error.
        CALL METHOD e_dragdropobj->abort.
        RETURN.
      ENDIF.
* drop on a folder, copy into this folder (and open it)
      IF ls_detail1-dir = 1 AND ls_detail1-name NE c_goto_parent_dir.
        CONCATENATE ls_detail1-path ls_detail1-name c_local_slash
                    INTO ls_detail1-path.
      ENDIF.

      PERFORM save_remote_to_local USING ls_detail2-path
                                         ls_detail2-name
                                         ls_detail1-path
                                         ls_detail2-name
                                         ls_detail2-filetransfermode
                                         c_open_no.
* if drop is folder, open tree on this folder
      IF ls_detail1-dir = 1 AND ls_detail1-name NE c_goto_parent_dir.
        READ TABLE t_nodes1 INTO s_node
                   WITH KEY path = ls_detail1-path.
        CALL METHOD o_tree1->set_selected_node
          EXPORTING
            node_key = s_node-node_key.
        PERFORM change_local_folder USING s_node-node_key.
      ELSE.
* if drop is file or contaner, refresh grid
        PERFORM get_local_folder_detail USING ls_detail1-path.
        PERFORM refresh_grid_display USING 1.
      ENDIF.
* if drag from grid 1 => move/copy file
*      ELSE.
* TODO
    ENDIF.
  ENDMETHOD.                    "handle_local_grid_drop

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_select
*&---------------------------------------------------------------------*
*       Handle clic on local tree node (folder) to display
*       the content in alv
*----------------------------------------------------------------------*
  METHOD handle_select.
* skip root node
    IF node_key = 'ROOT'.
      RETURN.
    ENDIF.
* When selecting a node, load and open subnodes, and display file list
    PERFORM change_local_folder USING node_key.
  ENDMETHOD.                    "handle_select

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_select_remote
*&---------------------------------------------------------------------*
*       Handle clic on remote tree node (folder) to display
*       the content in alv
*----------------------------------------------------------------------*
  METHOD handle_select_remote.
* When selecting a node, load and open subnodes, and display file list
    PERFORM change_remote_folder USING node_key.
  ENDMETHOD.                    "handle_select

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_grid_double_click
*&---------------------------------------------------------------------*
*       Handle doubleclic on local alv line to navigate
*----------------------------------------------------------------------*
  METHOD handle_grid_double_click.
    DATA lw_path(1000).
    DATA lw_filefullname TYPE string.
    DATA : lw_index TYPE i,
           lw_size TYPE i.

    READ TABLE t_details1 INTO s_detail1 INDEX es_row_no-row_id.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

* double click on a folder open this folder
    IF s_detail1-dir = 1.
      IF s_detail1-name = c_goto_parent_dir.
        lw_size = strlen( s_detail1-path ).
        lw_size = lw_size - 1.
        find_last_occurrence c_local_slash s_detail1-path(lw_size)
                             lw_index.
        IF sy-subrc NE 0.
          RETURN.
        ENDIF.
        lw_index = lw_index + 1.
        lw_path = s_detail1-path(lw_index).
      ELSE.
        CONCATENATE s_detail1-path s_detail1-name c_local_slash
                    INTO lw_path.
      ENDIF.
      READ TABLE t_nodes1 INTO s_node WITH KEY path = lw_path.
      CALL METHOD o_tree1->set_selected_node
        EXPORTING
          node_key = s_node-node_key.
      PERFORM change_local_folder USING s_node-node_key.

* Double click on a file to open it
    ELSE.
      CONCATENATE s_detail1-path s_detail1-name INTO lw_path.
      lw_filefullname = lw_path.
      CALL METHOD cl_gui_frontend_services=>execute
        EXPORTING
          document               = lw_filefullname
        EXCEPTIONS
          cntl_error             = 1
          error_no_gui           = 2
          bad_parameter          = 3
          file_not_found         = 4
          path_not_found         = 5
          file_extension_unknown = 6
          error_execute_failed   = 7
          synchronous_failed     = 8
          not_supported_by_gui   = 9
          OTHERS                 = 10.
      IF sy-subrc <> 0.
        MESSAGE 'Cannot open the local file/folder'(e27)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "handle_grid_double_click

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_grid_double_click_remot
*&---------------------------------------------------------------------*
*       Handle doubleclic on remote alv line to navigate
*----------------------------------------------------------------------*
  METHOD handle_grid_double_click_remot.
    DATA lw_path(1000).
    DATA : lw_index TYPE i,
           lw_size TYPE i.

    READ TABLE t_details2 INTO s_detail2 INDEX es_row_no-row_id.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

* double click on a folder open this folder
    IF s_detail2-dir = 1.
      IF s_detail2-name = c_goto_parent_dir.
        lw_size = strlen( s_detail2-path ).
        lw_size = lw_size - 1.
        find_last_occurrence o_server_command->slash
                            s_detail2-path(lw_size) lw_index.
        IF sy-subrc NE 0.
          RETURN.
        ENDIF.
        lw_index = lw_index + 1.
        lw_path = s_detail2-path(lw_index).
      ELSE.
        CONCATENATE s_detail2-path s_detail2-name o_server_command->slash
                    INTO lw_path.
      ENDIF.
      READ TABLE t_nodes2 INTO s_node WITH KEY path = lw_path.
      CALL METHOD o_tree2->set_selected_node
        EXPORTING
          node_key = s_node-node_key.
      PERFORM change_remote_folder USING s_node-node_key.

* Double click on a file to open it
    ELSE.
      PERFORM save_remote_to_local USING s_detail2-path s_detail2-name
                                         '' s_detail2-name
                                         s_detail2-filetransfermode
                                         c_open_yes.
    ENDIF.
  ENDMETHOD.                    "handle_grid_double_click_remote

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_grid_context_local
*&---------------------------------------------------------------------*
*       Handle call of local context menu to display specific menus
*----------------------------------------------------------------------*
  METHOD handle_grid_context_local.
    DATA : lt_row_no TYPE lvc_t_roid,
           ls_row_no TYPE lvc_s_roid.

* delete standard alv context menu
    CALL METHOD e_object->clear.

* get grid line
    CALL METHOD o_grid1->get_selected_rows
      IMPORTING
        et_row_no = lt_row_no.

* check context is called from a grid line
    READ TABLE lt_row_no INTO ls_row_no INDEX 1.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.
    READ TABLE t_details1 INTO s_detail1 INDEX ls_row_no-row_id.
    IF sy-subrc NE 0 OR s_detail1-name = c_goto_parent_dir.
      RETURN.
    ENDIF.

* Build context menu
    IF s_detail1-dir = 0.
* Open function for file
      CALL METHOD e_object->add_function
        EXPORTING
          text  = 'Open'(m01)
          icon  = '@10@'
          fcode = 'LF_OPEN'.
* Open as function for file
      CALL METHOD e_object->add_function
        EXPORTING
          text  = 'Open as...'(m34)
          icon  = '@10@'
          fcode = 'LF_OPENAS'.

* Open folder in explorer function for file
      CALL METHOD e_object->add_function
        EXPORTING
          text  = 'Open folder in Explorer'(m02)
          icon  = '@FO@'
          fcode = 'LF_OPEN_PARENT'.
    ELSE.
* Open folder in explorer function for folder
      CALL METHOD e_object->add_function
        EXPORTING
          text  = 'Open folder in Explorer'(m02)
          icon  = '@FO@'
          fcode = 'LF_OPEN'.
    ENDIF.
* Copy to clipboard function for file&folder
    CALL METHOD e_object->add_function
      EXPORTING
        text  = 'Copy path to clipboard'(m03)
        icon  = '@2U@'
        fcode = 'LF_COPYPATH'.

  ENDMETHOD.                    "handle_grid_context_local

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_grid_context
*&---------------------------------------------------------------------*
*       Handle call of remote context menu to display specific menus
*----------------------------------------------------------------------*
  METHOD handle_grid_context.
    DATA : lt_row_no TYPE lvc_t_roid,
           ls_row_no TYPE lvc_s_roid,
           lw_pos TYPE i,
           lw_extension(10) TYPE c.

* get grid line
    CALL METHOD o_grid2->get_selected_rows
      IMPORTING
        et_row_no = lt_row_no.

* delete standard alv context menu
* Cannot ask to grid to not create context menus because it also
* disable function in the same time, and we need function activated
* to call manually the "grid option" window (filter, advanced sort...)
    CALL METHOD e_object->clear.

* check context is called from a grid line
    READ TABLE lt_row_no INTO ls_row_no INDEX 1.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.
    READ TABLE t_details2 INTO s_detail2 INDEX ls_row_no-row_id.
    IF sy-subrc NE 0 OR s_detail2-name = c_goto_parent_dir.
      RETURN.
    ENDIF.

* Build context menu
    IF s_detail2-dir = 0.
* Open function for file
      IF s_auth-download = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Open'(m01)
            icon  = '@10@'
            fcode = 'RF_OPEN'.
      ENDIF.

* Open as text function for file
      IF s_auth-download = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Open as text'(m04)
            icon  = '@0P@'
            fcode = 'RF_OPEN_TXT'.
      ENDIF.

* Open as function for file
      IF s_auth-download = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Open as...'(m34)
            icon  = '@10@'
            fcode = 'RF_OPENAS'.
      ENDIF.
    ENDIF.

* Copy to clipboard function for file&folder
    IF s_auth-copy_path = abap_true.
      CALL METHOD e_object->add_function
        EXPORTING
          text  = 'Copy path to clipboard'(m03)
          icon  = '@2U@'
          fcode = 'RF_COPYPATH'.
    ENDIF.

    CALL METHOD e_object->add_separator.

* Compress function for file & folder
    IF s_auth-zip = abap_true.
      CALL METHOD e_object->add_function
        EXPORTING
          text  = 'Compress'(m05)
          icon  = '@12@'
          fcode = 'RF_COMPRESS'.
    ENDIF.

    IF s_detail2-dir = 0.
* Rename function for file
      IF s_auth-rename_file = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Rename File'(m06)
            icon  = '@G4@'
            fcode = 'RF_RENAME'.
      ENDIF.

* Duplicate function for file
      IF s_auth-duplicate_file = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Duplicate File'(m07)
            icon  = '@14@'
            fcode = 'RF_DUPLICATE'.
      ENDIF.

* Delete function for file
      IF s_auth-delete_file = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Delete File'(m08)
            icon  = '@11@'
            fcode = 'RF_DELETE'.
      ENDIF.
    ELSE.
* Rename function for folder
      IF s_auth-rename_folder = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Rename Folder'(m09)
            icon  = '@G4@'
            fcode = 'RF_RENAME'.
      ENDIF.

* Duplicate function for folder
      IF s_auth-duplicate_folder = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Duplicate Folder'(m10)
            icon  = '@14@'
            fcode = 'RF_DUPLICATE'.
      ENDIF.

* Delete function for folder
      IF s_auth-delete_folder = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Delete Folder'(m11)
            icon  = '@11@'
            fcode = 'RF_DELETE_FOLDER'.
      ENDIF.
    ENDIF.

* Check if clicked file is compressed (ZIP, TAR, GZ or BZ2)
* Uncompress function for compressed file
    IF s_auth-unzip = abap_true.
      IF s_detail2-dir = 0.
        find_last_occurrence '.'  s_detail2-name lw_pos.
        IF sy-subrc = 0.
          lw_extension = s_detail2-name+lw_pos.
          TRANSLATE lw_extension TO LOWER CASE.
          IF lw_extension = '.zip' OR lw_extension = '.bz2'
          OR lw_extension = '.tar' OR lw_extension = '.gz'.
            CALL METHOD e_object->add_function
              EXPORTING
                text  = 'Uncompress'(m12)
                icon  = '@12@'
                fcode = 'RF_UNCOMPRESS'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

* CHMOD file/directory
    IF o_server_command->attrib_mode = lif_server_command=>c_attrmode_chmod
    OR o_server_command->attrib_mode = lif_server_command=>c_attrmode_attrib.
      IF s_auth-chmod = abap_true.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Change Attributes'(m25)
            icon  = '@9Y@'
            fcode = 'RF_CHMOD'.
      ELSE.
        CALL METHOD e_object->add_function
          EXPORTING
            text  = 'Display Attributes'(m26)
            icon  = '@9Y@'
            fcode = 'RF_CHMOD'.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "handle_grid_context

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_toolbar
*&---------------------------------------------------------------------*
*       Handle remote grid toolbar display to add specific button
*----------------------------------------------------------------------*
  METHOD handle_toolbar.
    DATA : ls_toolbar TYPE stb_button,
           ls_detail2 LIKE s_detail2.

* Delete all standard toolbar buttons.
* Cannot ask to grid to not create buttons because it also disable
* function in the same time, and we need function activated to call
* manually the "grid option" window (filter, advanced sort...)
    REFRESH e_object->mt_toolbar.

* Append an icon to show transfer modes
    CLEAR ls_toolbar.
    ls_toolbar-function = 'FORCETM'.
    ls_toolbar-icon = '@AA@'.
    ls_toolbar-quickinfo = 'Choose Transfer Mode (Auto/asc/bin)'(m14).
    ls_toolbar-text = 'Transfer Mode'(m13).
    ls_toolbar-butn_type = 2.
    ls_toolbar-disabled = space.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* Refresh current folder display
    CLEAR ls_toolbar.
    ls_toolbar-function = 'REFRESH_DIR'.
    ls_toolbar-icon = '@42@'.
    ls_toolbar-quickinfo = 'Refresh current folder'(m16).
    ls_toolbar-text = 'Refresh'(m15).
    ls_toolbar-butn_type = 0.
    ls_toolbar-disabled = space.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* Display server shortcuts
    IF s_auth-shortcut = abap_true.
      IF NOT t_shortcuts IS INITIAL OR s_auth-create_shortcut = abap_true.
        CLEAR ls_toolbar.
        ls_toolbar-function = 'SHORTCUTS'.
        ls_toolbar-icon = '@8T@'.
        ls_toolbar-text = 'Shortcuts'(m17).
        ls_toolbar-butn_type = 2.
        ls_toolbar-disabled = space.
        APPEND ls_toolbar TO e_object->mt_toolbar.
      ENDIF.
    ENDIF.

* Open path from clipboard
    IF s_auth-paste_path = abap_true.
      CLEAR ls_toolbar.
      ls_toolbar-function = 'GOTOPATH'.
      ls_toolbar-icon = '@2V@'.
      ls_toolbar-text = 'Open path from clipboard'(m18).
      ls_toolbar-butn_type = 0.
      ls_toolbar-disabled = space.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

* Create folder
    IF s_auth-create_folder = abap_true.
      CLEAR ls_toolbar.
      ls_toolbar-function = 'NEWFOLDER'.
      ls_toolbar-icon = '@0Y@'.
      ls_toolbar-text = 'Create folder'(m19).
      ls_toolbar-butn_type = 0.
      ls_toolbar-disabled = space.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

* Download file
    IF s_auth-download = abap_true.
      CLEAR ls_toolbar.
      ls_toolbar-function = 'RF_DOWNLOAD'.
      ls_toolbar-icon = '@MC@'.
      ls_toolbar-text = 'Download'(m20).
      ls_toolbar-butn_type = 0.
      ls_toolbar-disabled = space.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

* Upload
    IF s_auth-upload = abap_true.
      CLEAR ls_toolbar.
      ls_toolbar-function = 'LF_UPLOAD'.
      ls_toolbar-icon = '@M8@'.
      ls_toolbar-text = 'Upload'(m21).
      ls_toolbar-butn_type = 0.
      ls_toolbar-disabled = space.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

* Calculate folder size
    IF s_auth-dirsize = abap_true
    AND s_customize-autodirsize = space.
      CLEAR ls_toolbar.
      ls_toolbar-function = 'DIRSIZE'.
      ls_toolbar-icon = '@0U@'.
      ls_toolbar-text = 'Folders size'(m28).
      ls_toolbar-butn_type = 0.
      ls_toolbar-disabled = space.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

    CLEAR ls_toolbar.
    ls_toolbar-function = cl_gui_alv_grid=>mc_fc_current_variant.
    ls_toolbar-icon = icon_alv_variants.
    ls_toolbar-text = 'Grid options'(m33).
    ls_toolbar-butn_type = 0.
    ls_toolbar-disabled = space.
    APPEND ls_toolbar TO e_object->mt_toolbar.


* Manage the "Remember" remote server
    READ TABLE t_details2 INTO ls_detail2 INDEX 1.
    IF sy-subrc = 0
    AND ( s_customize-root_path_len LE 1
          OR s_customize-root_path NE
             ls_detail2-path(s_customize-root_path_len) )
    AND ls_detail2-path(1) = o_server_command->slash
    AND ls_detail2-path+1(1) = o_server_command->slash.
      CLEAR ls_toolbar.
      READ TABLE t_server_link TRANSPORTING NO FIELDS
                 WITH KEY low = ls_detail2-path.
      IF sy-subrc = 0.
        ls_toolbar-icon = '@CR@'.
        ls_toolbar-text = 'Forget server connexion'(m30).
      ELSE.
        ls_toolbar-icon = '@CQ@'.
        ls_toolbar-text = 'Remember server connexion'(m29).
      ENDIF.
      ls_toolbar-function = 'REMEMBER_SERVER'.
      ls_toolbar-butn_type = 0.
      ls_toolbar-disabled = space.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.
  ENDMETHOD.                    "handle_toolbar

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_menu_button
*&---------------------------------------------------------------------*
*       Handle menu button click to display specific menus
*----------------------------------------------------------------------*
  METHOD handle_menu_button.
    DATA : lw_check,
           lw_fcode TYPE ui_func,
           lw_text TYPE gui_text.

    CASE e_ucomm.
* Transfer mode menu : build submenu list
* The menu corresponding to current value for transfer mode is checked
      WHEN 'FORCETM'.
* Transfer mode menu : Option "auto"
* (let file extension choose the transfer mode)
        IF w_force_transfer_mode IS INITIAL.
          lw_check = abap_true.
        ELSE.
          lw_check = space.
        ENDIF.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode   = 'TM_AUTO'
            text    = 'Auto'(m22)
            checked = lw_check.

* Transfer mode menu : Option "ASC"
* (force transfer mode to ASCII, text mode)
        IF w_force_transfer_mode = c_asc.
          lw_check = abap_true.
        ELSE.
          lw_check = space.
        ENDIF.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode   = 'TM_ASC'
            text    = 'Ascii (text mode)'(m23)
            checked = lw_check.

* Transfer mode menu : Option "BIN"
* (force transfer mode to binary)
        IF w_force_transfer_mode = c_bin.
          lw_check = abap_true.
        ELSE.
          lw_check = space.
        ENDIF.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode   = 'TM_BIN'
            text    = 'Binary mode'(m24)
            checked = lw_check.

* Shortcuts menu : built submenu list
      WHEN 'SHORTCUTS'.
* Server shortcuts
        LOOP AT t_shortcuts INTO s_shortcut.
          lw_fcode = sy-tabix.
          CONDENSE lw_fcode NO-GAPS.
          CONCATENATE 'SH_' lw_fcode INTO lw_fcode.
          lw_text = s_shortcut-aliass.
          CALL METHOD e_object->add_function
            EXPORTING
              fcode = lw_fcode
              text  = lw_text.
        ENDLOOP.
        IF s_auth-create_shortcut = abap_true.
          IF sy-subrc = 0.
            CALL METHOD e_object->add_separator.
          ENDIF.
          CALL METHOD e_object->add_function
            EXPORTING
              fcode = 'SHORTCUT_CREATE'
              text  = 'Create shortcut'(m27).
        ENDIF.
        IF s_auth-delete_shortcut = abap_true
        AND NOT t_shortcuts IS INITIAL.
          IF s_auth-create_shortcut NE abap_true.
            CALL METHOD e_object->add_separator.
          ENDIF.
          CALL METHOD e_object->add_function
            EXPORTING
              fcode = 'SHORTCUT_DELETE'
              text  = 'Delete shortcut'(m32).
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "handle_menu_button

*&---------------------------------------------------------------------*
*&      CLASS lcl_application
*&      METHOD handle_user_command
*&---------------------------------------------------------------------*
*       Handle grid user command to manage specific fcode
*       (menus & toolbar)
*----------------------------------------------------------------------*
  METHOD handle_user_command.
    DATA : lt_row_no TYPE lvc_t_roid,
           ls_row_no TYPE lvc_s_roid,
           lw_name LIKE s_detail2-name,
           lw_nodekey LIKE s_node-node_key,
           ls_detail1 LIKE s_detail1,
           ls_detail2 LIKE s_detail2,
           ls_node LIKE s_node,
           lw_string TYPE string,
           lw_index TYPE i.

* For event on remote grid file, check than a remote file/folder is
* selected
    IF e_ucomm(3) = 'RF_'.
      CALL METHOD o_grid2->get_selected_rows
        IMPORTING
          et_row_no = lt_row_no.

      CLEAR ls_detail2.
      READ TABLE lt_row_no INTO ls_row_no INDEX 1.
      IF sy-subrc = 0.
        READ TABLE t_details2 INTO ls_detail2 INDEX ls_row_no-row_id.
      ENDIF.
      IF sy-subrc NE 0 OR ls_detail2-name = c_goto_parent_dir.
        MESSAGE 'Please choose a remote item'(e05)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        RETURN.
      ENDIF.
    ENDIF.

* For event on local grid file, check than a locale file/folder is
* selected
    IF e_ucomm(3) = 'LF_'.
      CALL METHOD o_grid1->get_selected_rows
        IMPORTING
          et_row_no = lt_row_no.

      CLEAR ls_detail1.
      READ TABLE lt_row_no INTO ls_row_no INDEX 1.
      IF sy-subrc = 0.
        READ TABLE t_details1 INTO ls_detail1 INDEX ls_row_no-row_id.
      ENDIF.
      IF sy-subrc NE 0 OR ls_detail1-name = c_goto_parent_dir.
        MESSAGE 'Please choose a local item'(e06)
                TYPE c_msg_success DISPLAY LIKE c_msg_error.
        RETURN.
      ENDIF.
    ENDIF.

* List of events
    CASE e_ucomm.
* Download from remote server
      WHEN 'RF_DOWNLOAD'.
        IF ls_detail2-dir = 1.
          MESSAGE 'Please choose a remote file to download'(e01)
                  TYPE c_msg_success DISPLAY LIKE c_msg_error.
          RETURN.
        ENDIF.
        CALL METHOD o_tree1->get_selected_node
          IMPORTING
            node_key = lw_nodekey.
        READ TABLE t_nodes1 INTO ls_node WITH KEY node_key = lw_nodekey.
        IF sy-subrc NE 0 OR lw_nodekey = 'ROOT'.
          MESSAGE 'Please choose a local folder to download'(e08)
                  TYPE c_msg_success DISPLAY LIKE c_msg_error.
          RETURN.
        ENDIF.
        PERFORM save_remote_to_local USING ls_detail2-path
                                           ls_detail2-name
                                           ls_node-path ls_detail2-name
                                           ls_detail2-filetransfermode
                                           c_open_no.
        PERFORM get_local_folder_detail USING ls_node-path.
        PERFORM refresh_grid_display USING 1.

* Upload to remote server
      WHEN 'LF_UPLOAD'.
        IF ls_detail1-dir = 1.
          MESSAGE 'Please choose a local file to upload'(e03)
                  TYPE c_msg_success DISPLAY LIKE c_msg_error.
          RETURN.
        ENDIF.
        CALL METHOD o_tree2->get_selected_node
          IMPORTING
            node_key = lw_nodekey.
        READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = lw_nodekey.
        IF sy-subrc NE 0.
          MESSAGE 'Please choose a remote folder to upload'(e10)
                  TYPE c_msg_success DISPLAY LIKE c_msg_error.
          RETURN.
        ENDIF.
        PERFORM save_local_to_remote USING ls_detail1-path
                                           ls_detail1-name
                                           ls_node-path ls_detail1-name
                                           ls_detail1-filetransfermode.
        PERFORM get_remote_folder_detail USING ls_node-path.
        PERFORM refresh_grid_display USING 2.

* Open remote file
      WHEN 'RF_OPEN'.
        PERFORM save_remote_to_local USING ls_detail2-path
                                           ls_detail2-name
                                           '' ls_detail2-name
                                           ls_detail2-filetransfermode
                                           c_open_yes.
* Open remote file as text
      WHEN 'RF_OPEN_TXT'.
        CONCATENATE s_detail2-name '.TXT' INTO lw_name.
        PERFORM save_remote_to_local USING ls_detail2-path
                                           ls_detail2-name
                                           '' lw_name
                                           ls_detail2-filetransfermode
                                           c_open_yes.

* Open remote file as text
      WHEN 'RF_OPENAS'.
        PERFORM save_remote_to_local USING ls_detail2-path
                                           ls_detail2-name
                                           '' ls_detail2-name
                                           ls_detail2-filetransfermode
                                           c_open_as.

* Open local file or folder in Explorer
      WHEN 'LF_OPEN' OR 'LF_OPEN_PARENT'.
* Open file or folder
        IF e_ucomm = 'LF_OPEN'.
          CONCATENATE s_detail1-path s_detail1-name INTO lw_name.
* Add final slash for folder
          IF ls_detail1-dir = 1.
            CONCATENATE lw_name c_local_slash INTO lw_name.
          ENDIF.
* Open parent folder
        ELSE.
          lw_name = s_detail1-path.
        ENDIF.
        lw_string = lw_name.

        CALL METHOD cl_gui_frontend_services=>execute
          EXPORTING
            document               = lw_string
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10.
        IF sy-subrc <> 0.
          MESSAGE 'Cannot open the local file/folder'(e27)
                  TYPE c_msg_success DISPLAY LIKE c_msg_error.
        ENDIF.

* Open the "open as" window to select application
      WHEN 'LF_OPENAS'.
        CONCATENATE s_detail1-path s_detail1-name INTO lw_name.
        lw_string = lw_name.
        CONCATENATE 'SHELL32.DLL,OpenAs_RunDLL' lw_string
                    INTO lw_string SEPARATED BY space.
        CALL METHOD cl_gui_frontend_services=>execute
          EXPORTING
            application            = 'RUNDLL32.EXE'
            parameter              = lw_string
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10.
        IF sy-subrc <> 0.
          MESSAGE 'Cannot open the local file/folder'(e27)
                  TYPE c_msg_success DISPLAY LIKE c_msg_error.
        ENDIF.

* Compress remote file
      WHEN 'RF_COMPRESS'.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM compress_item USING lw_name.
        PERFORM get_remote_folder_detail USING ls_detail2-path.
        PERFORM refresh_grid_display USING 2.

* Uncompress remote file
      WHEN 'RF_UNCOMPRESS'.
        PERFORM uncompress_file USING ls_detail2-path ls_detail2-name.
        READ TABLE t_nodes2 INTO ls_node
             WITH KEY path = ls_detail2-path.
        PERFORM refresh_tree2 USING ls_node.

* Delete remote file
      WHEN 'RF_DELETE'.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM delete_file USING lw_name.
        PERFORM get_remote_folder_detail USING ls_detail2-path.
        PERFORM refresh_grid_display USING 2.

* Duplicate remote file
      WHEN 'RF_DUPLICATE'.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM duplicate_item USING lw_name ls_detail2-dir.
* if duplicate a folder, refresh tree
        IF ls_detail2-dir = 1.
          READ TABLE t_nodes2 INTO ls_node
                     WITH KEY path = ls_detail2-path.
          PERFORM refresh_tree2 USING ls_node.
* if duplicate a file, refresh grid only
        ELSE.
          PERFORM get_remote_folder_detail USING ls_detail2-path.
          PERFORM refresh_grid_display USING 2.
        ENDIF.

* Rename remote file
      WHEN 'RF_RENAME'.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM rename_item USING ls_detail2-path ls_detail2-name
                ls_detail2-dir.
* if duplicate a folder, refresh tree
        IF ls_detail2-dir = 1.
          READ TABLE t_nodes2 INTO ls_node
                     WITH KEY path = ls_detail2-path.
          PERFORM refresh_tree2 USING ls_node.
* if duplicate a file, refresh grid only
        ELSE.
          PERFORM get_remote_folder_detail USING ls_detail2-path.
          PERFORM refresh_grid_display USING 2.
        ENDIF.

* Delete remote folder
      WHEN 'RF_DELETE_FOLDER'.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM delete_folder USING lw_name.
        READ TABLE t_nodes2 INTO ls_node
                   WITH KEY path = ls_detail2-path.
        PERFORM refresh_tree2 USING ls_node.

* Copy remote path to clipboard
      WHEN 'RF_COPYPATH'.
        CONCATENATE ls_detail2-path ls_detail2-name INTO lw_name.
        PERFORM clipboard_export USING lw_name 1.

* Copy local path to clipboard
      WHEN 'LF_COPYPATH'.
        CONCATENATE ls_detail1-path ls_detail1-name INTO lw_name.
        PERFORM clipboard_export USING lw_name 0.

* Open remote folder from clipboard
      WHEN 'GOTOPATH'.
        PERFORM clipboard_import.

* Change transfer mode to "auto"
      WHEN 'TM_AUTO'.
        CLEAR w_force_transfer_mode.

* Change transfer mode to "ASC"
      WHEN 'TM_ASC'.
        w_force_transfer_mode = c_asc.

* Change transfer mode to "BIN"
      WHEN 'TM_BIN'.
        w_force_transfer_mode = c_bin.

* Calculate directory size
      WHEN 'DIRSIZE'.
        PERFORM get_remote_folder_size.
* REFRESH grid2 display
        PERFORM refresh_grid_display USING 2.

* Refresh current remote folder
      WHEN 'REFRESH_DIR'.
* get current folder
        CALL METHOD o_tree2->get_selected_node
          IMPORTING
            node_key = lw_nodekey.
        READ TABLE t_nodes2 INTO s_node WITH KEY node_key = lw_nodekey.
* Refresh folder content
        PERFORM get_remote_folder_detail USING s_node-path.
* Refresh display
        PERFORM refresh_grid_display USING 2.

* Create remote folder
      WHEN 'NEWFOLDER'.
* Get current folder
        CALL METHOD o_tree2->get_selected_node
          IMPORTING
            node_key = lw_nodekey.
        READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = lw_nodekey.
* Create new folder
        PERFORM create_folder USING ls_node-path.
* Refresh tree
        PERFORM refresh_tree2 USING ls_node.

* Create a server shortcut
      WHEN 'SHORTCUT_CREATE'.
* Get current folder
        CALL METHOD o_tree2->get_selected_node
          IMPORTING
            node_key = lw_nodekey.
        READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = lw_nodekey.
* Create the shortcut
        PERFORM create_shortcut USING ls_node-path.

* Delete a server shortcut
      WHEN 'SHORTCUT_DELETE'.
* Display the shortcut deletion popup
        PERFORM delete_shortcut.

* CHMOD File/folder
      WHEN 'RF_CHMOD'.
        CALL METHOD o_tree2->get_selected_node
          IMPORTING
            node_key = lw_nodekey.

        IF o_server_command->attrib_mode = lif_server_command=>c_attrmode_chmod.
          PERFORM chmod USING ls_detail2-path ls_detail2-name
                              ls_detail2-mode ls_detail2-owner.
        ELSEIF o_server_command->attrib_mode = lif_server_command=>c_attrmode_attrib.
          PERFORM attrib USING ls_detail2-path ls_detail2-name
                               ls_detail2-attrs.
        ENDIF.
        PERFORM change_remote_folder USING lw_nodekey.

* Add/remove server link in variant
      WHEN 'REMEMBER_SERVER'.
        CALL METHOD o_tree2->get_selected_node
          IMPORTING
            node_key = lw_nodekey.
        READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = lw_nodekey.
        PERFORM manage_server_link USING ls_node-path.
        PERFORM refresh_grid_display USING 2.
      WHEN OTHERS.
* Goto shortcut
        IF e_ucomm(3) = 'SH_'.
          lw_index = e_ucomm+3.
          READ TABLE t_shortcuts INTO s_shortcut INDEX lw_index.
          IF sy-subrc NE 0.
            RETURN.
          ENDIF.
          PERFORM goto_shortcut USING s_shortcut-dirname 1 space.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "handle_user_command
ENDCLASS.                    "lcl_application IMPLEMENTATION

*######################################################################*
*
*                             MAIN SECTION
*
*######################################################################*
START-OF-SELECTION.
  CALL SCREEN 100.


*######################################################################*
*
*                             PBO SECTION
*
*######################################################################*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Set status for main screen
*       and initialize custom container at first run
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'SCREEN100'. "Define function EXIT to leave the screen
  SET TITLEBAR 'TITLE100'.   "ABAP FTP

  IF o_container IS INITIAL.
    PERFORM init_auth.
    PERFORM init_screen.
  ENDIF.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       Set status for main screen
*       and initialize custom container at first run
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'SCREEN200'. "Define function EXIT to leave the screen
  SET TITLEBAR 'TITLE200'.   "Change Attributes
  IF o_container_chmod IS INITIAL.
    IF o_server_command->attrib_mode = lif_server_command=>c_attrmode_chmod.
      PERFORM init_chmod.
    ELSEIF o_server_command->attrib_mode = lif_server_command=>c_attrmode_attrib.
      PERFORM init_attrib.
    ENDIF.
  ELSEIF w_chmod_to_set IS NOT INITIAL
  OR w_owner_to_set IS NOT INITIAL
  OR w_attrib_to_set IS NOT INITIAL.
    IF o_server_command->attrib_mode = lif_server_command=>c_attrmode_chmod.
      PERFORM update_chmod.
    ELSEIF o_server_command->attrib_mode = lif_server_command=>c_attrmode_attrib.
      PERFORM update_attrib.
    ENDIF.
  ENDIF.
ENDMODULE.                 " STATUS_0200  OUTPUT

*######################################################################*
*
*                             PAI SECTION
*
*######################################################################*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       PAI module to exit screen
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  IF w_okcode = 'EXIT'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " EXIT_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  IF w_okcode = 'CLOSE' OR w_okcode = 'OK'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0200  INPUT

*######################################################################*
*
*                             FORM SECTION
*
*######################################################################*

*&---------------------------------------------------------------------*
*&      Form  INIT_SCREEN
*&---------------------------------------------------------------------*
*       Initialize all objects of the screen
*----------------------------------------------------------------------*
FORM init_screen .
* Init server
  IF sy-opsys(3) = 'Win' OR sy-opsys(3) = 'WIN'
  OR sy-opsys CS 'Windows'.
    CREATE OBJECT o_server_command TYPE lcl_windows_server.
  ELSE.
    CREATE OBJECT o_server_command TYPE lcl_aix_server.
  ENDIF.

* Init shared memory variable
  CONCATENATE 'ZAL11_L_' sy-uname INTO w_shared_dir_local.
  CONCATENATE 'ZAL11_R_' sy-uname INTO w_shared_dir_remote.

* Split the screen into 4 parts
  PERFORM init_splitter.

* Fill first part with a tree of the local folders
  PERFORM init_tree1.

* Fill second part with an ALV grid of the local folder content
  PERFORM init_detail1.

* Try to open last used nodes
  IMPORT w_path FROM SHARED BUFFER indx(st) ID w_shared_dir_local.
  IF sy-subrc = 0 AND NOT w_path IS INITIAL.
    PERFORM goto_shortcut_local USING w_path.
  ELSE.
* Open first local drive (content is displayed in the alv grid)
    READ TABLE t_nodes1 INTO s_node INDEX 2.
    IF sy-subrc = 0.
      CALL METHOD o_tree1->set_selected_node
        EXPORTING
          node_key = s_node-node_key.
      PERFORM change_local_folder USING s_node-node_key.
    ELSE.
      MESSAGE 'Please allow SAP to access to your local files'(e24)
              TYPE c_msg_success DISPLAY LIKE c_msg_error.
    ENDIF.
  ENDIF.

* Get the root path for the user
  PERFORM init_root_path.

* Fill third part with a tree of the remote folders
  PERFORM init_tree2.

* Fill last part with an ALV grid of the remote folder content
  PERFORM init_detail2.

* Get list of distant server and add them to tree
  PERFORM get_server_link.

* Try to open last used nodes
  IMPORT w_path FROM SHARED BUFFER indx(st) ID w_shared_dir_remote.
  IF sy-subrc = 0 AND NOT w_path IS INITIAL
  AND NOT w_path = s_customize-root_path.
    PERFORM goto_shortcut USING w_path 2 space.
  ELSE.
* Open root node (content is displayed in the alv grid)
    CALL METHOD o_tree2->set_selected_node
      EXPORTING
        node_key = 'ROOT'.
    PERFORM change_remote_folder USING 'ROOT'.
  ENDIF.

ENDFORM.                    " INIT_SCREEN
*&---------------------------------------------------------------------*
*&      Form  INIT_SPLITTER
*&---------------------------------------------------------------------*
*       Split the main screen into 4 parts
*----------------------------------------------------------------------*
FORM init_splitter .
* Create the custom container
  CREATE OBJECT o_container
    EXPORTING
      container_name = 'CUSTCONT'.

* Create the handle object (required to catch events)
  CREATE OBJECT o_handle_event.

* Insert splitter into this container
  CREATE OBJECT o_splitter
    EXPORTING
      parent  = o_container
      rows    = 2
      columns = 1.

* To allow columns in high part to be independant of columns in lower part,
* we need to split in 2 times

* Get the first row of the main splitter
  CALL METHOD o_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = o_container_h.

*  Spliter for the high part (first row)
  CREATE OBJECT o_splitter_h
    EXPORTING
      parent  = o_container_h
      rows    = 1
      columns = 2.

* Affect an object to each "cell" of the high sub splitter
  CALL METHOD o_splitter_h->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = o_container_tree1.

  CALL METHOD o_splitter_h->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = o_container_detail1.

* Get the second row of the main splitter
  CALL METHOD o_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = o_container_l.

*  Spliter for the high part (first row)
  CREATE OBJECT o_splitter_l
    EXPORTING
      parent  = o_container_l
      rows    = 1
      columns = 2.

* Affect an object to each "cell" of the low sub splitter
  CALL METHOD o_splitter_l->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = o_container_tree2.

  CALL METHOD o_splitter_l->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = o_container_detail2.

* Set first col initial size to 40%
  CALL METHOD o_splitter_h->set_column_width
    EXPORTING
      id    = 1
      width = 20.
  CALL METHOD o_splitter_l->set_column_width
    EXPORTING
      id    = 1
      width = 20.

ENDFORM.                    " INIT_SPLITTER

*&---------------------------------------------------------------------*
*&      Form  INIT_TREE1
*&---------------------------------------------------------------------*
*       Initialize local tree
*----------------------------------------------------------------------*
FORM init_tree1 .
  DATA: lt_event TYPE cntl_simple_events,
        ls_event TYPE cntl_simple_event,
        lw_effect TYPE i.

* Create a tree control
  CREATE OBJECT o_tree1
    EXPORTING
      parent              = o_container_tree1
      node_selection_mode = cl_gui_simple_tree=>node_sel_mode_single
    EXCEPTIONS
      lifetime_error      = 1
      cntl_system_error   = 2
      create_error        = 3
      failed              = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Catch selection to open folder content
  ls_event-eventid = cl_gui_simple_tree=>eventid_selection_changed.
  ls_event-appl_event = abap_true. " no PAI if event occurs
  APPEND ls_event TO lt_event.

  CALL METHOD o_tree1->set_registered_events
    EXPORTING
      events                    = lt_event
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Assign event handlers in the application class to each desired event
  SET HANDLER o_handle_event->handle_select FOR o_tree1.
  SET HANDLER o_handle_event->handle_local_tree_drop FOR o_tree1.

* Define drag&drop type allowed (copy and move)
  lw_effect = cl_dragdrop=>copy.
  CREATE OBJECT o_dragdrop_tree1.
  CALL METHOD o_dragdrop_tree1->add
    EXPORTING
      flavor     = 'LINE'
      dragsrc    = space
      droptarget = abap_true
      effect     = lw_effect.
  CALL METHOD o_dragdrop_tree1->get_handle
    IMPORTING
      handle = w_handle_tree1.

* Initialize local tree content
  CLEAR w_node1_count.
  PERFORM init_local_dir.
ENDFORM.                    " INIT_TREE1

*&---------------------------------------------------------------------*
*&      Form  INIT_LOCAL_DIR
*&---------------------------------------------------------------------*
*       Initialize local tree content
*----------------------------------------------------------------------*
FORM init_local_dir.
  DATA : lw_pcname TYPE string,
         lw_special_path TYPE string.

  REFRESH t_nodes1.

* Get the name of the local PC
  CALL METHOD cl_gui_frontend_services=>get_computer_name
    CHANGING
      computer_name        = lw_pcname
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CALL METHOD cl_gui_cfw=>flush.

* get list of local drive letters
  PERFORM init_local_drives.

* Node with key 'Root'
  CLEAR s_node.
  s_node-node_key = 'ROOT'.
  s_node-hidden = space.
  s_node-disabled = space.
  s_node-isfolder = abap_true.
  s_node-read = abap_true. "to avoid trying to read this fake folder
  s_node-n_image = s_node-exp_image = '@MV@'.
  CONCATENATE 'Local PC'(c01) lw_pcname INTO s_node-text
              SEPARATED BY space.
  APPEND s_node TO t_nodes1.

* Add Desktop folder
  PERFORM get_windows_special_folders USING 'Desktop'       "#EC NOTEXT
                                      CHANGING lw_special_path.
  IF NOT lw_special_path IS INITIAL.
    CLEAR s_node.
    s_node-node_key = 'DESKTOP'.
    s_node-relatkey = 'ROOT'.
    s_node-relatship = cl_gui_simple_tree=>relat_last_child.
    s_node-isfolder = abap_true.
    s_node-text = 'Desktop'(h32).
    s_node-n_image = s_node-exp_image = '@JF@'.
    CONCATENATE lw_special_path c_local_slash INTO s_node-path.
    s_node-dragdropid = w_handle_tree1.
    APPEND s_node TO t_nodes1.
  ENDIF.

* Add my Documents folder
  PERFORM get_windows_special_folders USING 'Personal'      "#EC NOTEXT
                                      CHANGING lw_special_path.
  IF NOT lw_special_path IS INITIAL.
    CLEAR s_node.
    s_node-node_key = 'MYDOC'.
    s_node-relatkey = 'ROOT'.
    s_node-relatship = cl_gui_simple_tree=>relat_last_child.
    s_node-isfolder = abap_true.
    s_node-text = 'My Documents'(h33).
    s_node-n_image = s_node-exp_image = '@F8@'.
    CONCATENATE lw_special_path c_local_slash INTO s_node-path.
    s_node-dragdropid = w_handle_tree1.
    APPEND s_node TO t_nodes1.
  ENDIF.

* Define each drive as child of the 'ROOT' node
  LOOP AT t_drives INTO s_drive.
    CLEAR s_node.
    s_node-node_key = s_drive-drive.
    s_node-relatkey = 'ROOT'.
    s_node-relatship = cl_gui_simple_tree=>relat_last_child.
    s_node-isfolder = abap_true.
    s_node-text = s_drive-desc.
    s_node-path(1) = s_drive-drive.
    s_node-path+1 = ':\'.
    CASE s_drive-type.
      WHEN c_drivetype_hdd.
        s_node-n_image = s_node-exp_image = '@4V@'.
      WHEN c_drivetype_cd.
        s_node-n_image = s_node-exp_image = '@4W@'.
      WHEN c_drivetype_remote.
        s_node-n_image = s_node-exp_image = '@53@'.
      WHEN c_drivetype_usb.
        s_node-n_image = s_node-exp_image = '@63@'.
      WHEN OTHERS.
*            s_drive-desc = 'Unknown (#:)'(c06).
    ENDCASE.
    s_node-dragdropid = w_handle_tree1.
    APPEND s_node TO t_nodes1.
  ENDLOOP.

  CALL METHOD o_tree1->add_nodes
    EXPORTING
      table_structure_name           = 'MTREESNODE'
      node_table                     = t_nodes1
    EXCEPTIONS
      failed                         = 1
      error_in_node_table            = 2
      dp_error                       = 3
      table_structure_name_not_found = 4
      OTHERS                         = 5.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Expand the root node to display all drives in the tree
  CALL METHOD o_tree1->expand_root_nodes.
ENDFORM.                    " INIT_LOCAL_DIR

*&---------------------------------------------------------------------*
*&      Form  init_local_drives
*&---------------------------------------------------------------------*
*       Initialize list of local drive letters into t_drives
*----------------------------------------------------------------------*
FORM init_local_drives.
  DATA : lw_abcde TYPE syabcde,
         lw_drivetemplate TYPE char3 VALUE ' :\',
         lw_drivetotest TYPE string,
         lw_type TYPE string.

* Get all letters, remove AB which is assumed as floppy disk
  lw_abcde = sy-abcde.
  SHIFT lw_abcde BY 2 PLACES.
  CONDENSE lw_abcde NO-GAPS.
  CLEAR: t_drives, s_drive.

* Check if each letter is mounted
  WHILE lw_abcde IS NOT INITIAL.
    lw_drivetemplate(1) = lw_abcde(1).
    lw_drivetotest = lw_drivetemplate.
    SHIFT lw_abcde BY 1 PLACES.
    CLEAR lw_type.
* Get Drive Type
    CALL METHOD cl_gui_frontend_services=>get_drive_type
      EXPORTING
        drive                = lw_drivetotest
      CHANGING
        drive_type           = lw_type
      EXCEPTIONS
        cntl_error           = 1
        bad_parameter        = 2
        error_no_gui         = 3
        not_supported_by_gui = 4
        OTHERS               = 5.
    IF sy-subrc = 0.
      CALL METHOD cl_gui_cfw=>flush.
* If letter exist on local PC, get drive type
      IF lw_type IS NOT INITIAL.
        s_drive-drive = lw_drivetotest.
        s_drive-type = lw_type.
        CASE s_drive-type.
          WHEN c_drivetype_hdd.
            s_drive-desc = 'Local Disk (#:)'(c02).
          WHEN c_drivetype_cd.
            s_drive-desc = 'CDROM Drive (#:)'(c03).
          WHEN c_drivetype_remote.
            s_drive-desc = 'Remote Drive (#:)'(c04).
          WHEN c_drivetype_usb.
            s_drive-desc = 'Removable Drive (#:)'(c05).
          WHEN OTHERS.
            s_drive-desc = 'Unknown (#:)'(c06).
        ENDCASE.
        REPLACE c_wildcard WITH s_drive-drive(1) INTO s_drive-desc.
        APPEND s_drive TO t_drives.
      ENDIF.
    ENDIF.
  ENDWHILE.
ENDFORM. " init_local_drives

*&---------------------------------------------------------------------*
*&      Form  INIT_DETAIL1
*&---------------------------------------------------------------------*
*       Initialize local grid object
*----------------------------------------------------------------------*
FORM init_detail1.
  DATA : lw_effect TYPE i.

* Create grid object
  CREATE OBJECT o_grid1
    EXPORTING
      i_parent = o_container_detail1.

* Set all grid event to handle
  SET HANDLER o_handle_event->handle_grid_double_click FOR o_grid1.
  SET HANDLER o_handle_event->handle_grid_context_local FOR o_grid1.
  SET HANDLER o_handle_event->handle_user_command FOR o_grid1.
  SET HANDLER o_handle_event->handle_grid_drag FOR o_grid1.
  SET HANDLER o_handle_event->handle_local_grid_drop FOR o_grid1.

  READ TABLE t_drives INTO s_drive INDEX 1.

* Define drag&drop type allowed (copy and move)
  lw_effect = cl_dragdrop=>move + cl_dragdrop=>copy.
  CREATE OBJECT o_dragdrop_grid1.
  CALL METHOD o_dragdrop_grid1->add
    EXPORTING
      flavor     = 'LINE'
      dragsrc    = abap_true
      droptarget = abap_true
      effect     = lw_effect.
  CALL METHOD o_dragdrop_grid1->get_handle
    IMPORTING
      handle = w_handle_grid1.

* Fill config ALV var
  PERFORM init_detail1_alv.

* Set the grid config and content
  CALL METHOD o_grid1->set_table_for_first_display
    EXPORTING
      is_layout       = s_layout_grid1
    CHANGING
      it_outtab       = t_details1
      it_fieldcatalog = t_fieldcat_grid1[]
      it_sort         = t_sort_grid1[].

ENDFORM.                    " INIT_DETAIL1

*&---------------------------------------------------------------------*
*&      Form  GET_local_FOLDER_DETAIL
*&---------------------------------------------------------------------*
*       Get list of files for a given local path
*       Read the local folder given and fill t_details2
*----------------------------------------------------------------------*
*      -->PW_PATH  Local Path to read
*----------------------------------------------------------------------*
FORM get_local_folder_detail USING pw_path TYPE c.

  DATA: lt_files TYPE STANDARD TABLE OF file_info,
        ls_file TYPE file_info,
        lw_count TYPE i,
        lw_path_name TYPE string,
        lw_fileupper LIKE ls_file-filename.

  lw_path_name = pw_path.
  REFRESH : t_details1, lt_files.

* Get Folders in a Given Directory
  CALL METHOD cl_gui_frontend_services=>directory_list_files
    EXPORTING
      directory                   = lw_path_name
    CHANGING
      file_table                  = lt_files
      count                       = lw_count
    EXCEPTIONS
      cntl_error                  = 1
      directory_list_files_failed = 2
      wrong_parameter             = 3
      error_no_gui                = 4
      not_supported_by_gui        = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* if folder is not a root, add '..' to go on parent dir
  lw_count = strlen( lw_path_name ).
  IF lw_count > 3.
    CLEAR: s_detail1.
    s_detail1-path = lw_path_name.
    s_detail1-name = c_goto_parent_dir.
    s_detail1-dir = 1.
    s_detail1-icon = '@IH@'.
    s_detail1-filetype = 'Directory'(c07).
    APPEND s_detail1 TO t_details1.
  ENDIF.

* List content of the path
  LOOP AT lt_files INTO ls_file.
    CLEAR: s_detail1.
    s_detail1-path = lw_path_name.
    s_detail1-name = ls_file-filename.
    s_detail1-dir = ls_file-isdir.
* Add trash icon for windows recycle bin entry
    lw_fileupper = ls_file-filename.
    TRANSLATE lw_fileupper TO UPPER CASE.
    IF lw_fileupper = '$RECYCLE.BIN'.
      s_detail1-icon = '@11@'.
      s_detail1-filetype = 'Trash bin'(c55).
* Add folder icon for directories
    ELSEIF ls_file-isdir = 1.
      s_detail1-icon = '@IH@'.
      s_detail1-filetype = 'Directory'(c07).
    ELSE.
* for files, get icon and default transfer mode
      PERFORM get_filetype USING s_detail1-name
                           CHANGING s_detail1-icon
                                    s_detail1-filetype
                                    s_detail1-filetransfermode.
    ENDIF.
    s_detail1-len = ls_file-filelength.
    s_detail1-ctime = ls_file-createtime.
    s_detail1-cdate = ls_file-createdate.
    s_detail1-rdate = ls_file-accessdate.
    s_detail1-rtime = ls_file-accesstime.
    s_detail1-mdate = ls_file-writedate.
    s_detail1-mtime = ls_file-writetime.
    IF ls_file-isreadonly NE 0.
      CONCATENATE s_detail1-attrs 'R' INTO s_detail1-attrs.
    ENDIF.
    IF ls_file-isarchived NE 0.
      CONCATENATE s_detail1-attrs 'A' INTO s_detail1-attrs.
    ENDIF.
    IF ls_file-issystem NE 0.
      CONCATENATE s_detail1-attrs 'S' INTO s_detail1-attrs.
    ENDIF.
    IF ls_file-ishidden NE 0.
      CONCATENATE s_detail1-attrs 'H' INTO s_detail1-attrs.
    ENDIF.
    IF ls_file-iscompress NE 0.
      CONCATENATE s_detail1-attrs 'C' INTO s_detail1-attrs.
    ENDIF.
    APPEND s_detail1 TO t_details1.
  ENDLOOP.

ENDFORM.                    " GET_local_FOLDER_DETAIL

*&---------------------------------------------------------------------*
*&      Form  GET_FILETYPE
*&---------------------------------------------------------------------*
*       For a given file, found his type and return icon, text and
*       transfer mode
*----------------------------------------------------------------------*
*      -->PW_NAME  File name
*      <--PW_ICON  File icon
*      <--PW_FILETYPE File type text
*      <--PW_FILETRANSFERMODE File transfer mode (BIN/ASC)
*----------------------------------------------------------------------*
FORM get_filetype  USING    pw_name TYPE c
                   CHANGING pw_icon TYPE c
                            pw_filetype TYPE c
                            pw_filetransfermode TYPE c.
  DATA : lw_ext(10),
         lt_chunk LIKE STANDARD TABLE OF lw_ext,
         lw_count TYPE i.

* Macro to set specific file type
  DEFINE set_type.
    pw_icon = &1.
    pw_filetransfermode = &2.
    pw_filetype = &3.
  END-OF-DEFINITION.

* Macro to set generic file type
  DEFINE set_type_gen.
    pw_icon = &1.
    pw_filetype = '# File'(c54).
    replace c_wildcard with lw_ext into pw_filetype.
    condense pw_filetype.
    pw_filetransfermode = c_bin.
  END-OF-DEFINITION.

* Get extension of the given file
  SPLIT pw_name AT '.' INTO TABLE lt_chunk.
  DESCRIBE TABLE lt_chunk LINES lw_count.
  IF lw_count < 2.
    CLEAR lw_ext.
  ELSE.
    READ TABLE lt_chunk INTO lw_ext INDEX lw_count.
  ENDIF.
  TRANSLATE lw_ext TO UPPER CASE.

* find file type from extension
  CASE lw_ext.
    WHEN 'TXT'.
      set_type '@EQ@' c_asc 'Text Document'(c08).
    WHEN 'INI'.
      set_type '@EQ@' c_asc 'Configuration Settings'(c09).
    WHEN 'SAP'.
      set_type '@E3@' c_bin 'SAP GUI Shortcut'(c10).
    WHEN 'CFG'.
      set_type '@EQ@' c_asc 'CFG File'(c11).
    WHEN 'LOG'.
      set_type '@DR@' c_asc 'Log File'(c12).
    WHEN 'DOC' OR 'DOCX'.
      set_type '@J7@' c_bin 'MS Word Document'(c13).
    WHEN 'ITS'.
      set_type '@IZ@' c_bin 'Internet Document Set'(c14).
    WHEN 'INF'.
      set_type '@9E@' c_bin 'Setup Information'(c15).
    WHEN 'HTM' OR 'HTML'.
      set_type '@J4@' c_bin 'HTML Document'(c16).
    WHEN 'HTT'.
      set_type '@IY@' c_bin 'HyperText Template'(c17).
    WHEN 'URL'.
      set_type '@8S@' c_bin 'Internet Shortcut'(c18).
    WHEN 'XML'.
      set_type '@IZ@' c_bin 'XML Document'(c19).
    WHEN 'HLP' OR 'CFM'.
      set_type '@5E@' c_bin 'Help File'(c20).
    WHEN 'SYS'.
      set_type '@O8@' c_bin 'System file'(c21).
    WHEN 'CMD'.
      set_type '@IF@' c_bin 'Windows Command Script'(c22).
    WHEN 'CAT'.
      set_type '@O8@' c_bin 'Security Catalog'(c23).
    WHEN 'DLL'.
      set_type '@O8@' c_bin 'Application Extension'(c24).
    WHEN 'DRV'.
      set_type '@O8@' c_bin 'Device driver'(c25).
    WHEN 'TTF'.
      set_type '@AI@' c_bin 'TrueType Font'(c26).
    WHEN 'OLD'.
      set_type '@DH@' c_bin 'OLD File'(c27).
    WHEN 'SPC'.
      set_type '@9P@' c_bin 'PKCS Certificates'(c28).
    WHEN 'EXE'.
      set_type '@9X@' c_bin 'Application'(c29).
    WHEN 'BAT'.
      set_type '@9U@' c_asc 'MS-DOS Batch File'(c30).
    WHEN 'PPT'.
      set_type '@J5@' c_bin 'MS PowerPoint Presentation'(c31).
    WHEN 'DOT'.
      set_type '@J6@' c_bin 'MS Word Template'(c32).
    WHEN 'EML'.
      set_type '@J8@' c_bin 'Outlook Mail Message'(c33).
    WHEN 'RTF'.
      set_type '@J9@' c_bin 'Rich Text Format'(c34).
    WHEN 'PDF'.
      set_type '@IT@' c_bin 'Adobe Acrobat Document'(c35).
    WHEN 'TIF'.
      set_type '@JA@' c_bin 'TIF Image Document'(c36).
    WHEN 'ICO'.
      set_type '@GZ@' c_bin 'Icon'(c37).                  "#EC TEXT_DUP
    WHEN 'GIF'.
      set_type '@IW@' c_bin 'GIF Image'(c38).
    WHEN 'WRI'.
      set_type '@JB@' c_bin 'Write Document'(c39).
    WHEN 'OTF'.
      set_type '@OA@' c_bin 'OTF Document'(c40).
    WHEN 'VSD'.
      set_type '@JE@' c_bin 'MS Visio Document'(c41).
    WHEN 'BMP'.
      set_type '@IU@' c_bin 'Bitmap Image'(c42).
    WHEN 'PNG'.
      set_type '@IU@' c_bin 'PNG Image'(c43).
    WHEN 'XLS' OR 'XLSX'.
      set_type '@J2@' c_bin 'MS Excel Worksheet'(c44).
    WHEN 'CSV'.
      set_type '@J2@' c_asc 'MS Excel CSV'(c45).
    WHEN 'JPG' OR 'JPEG'.
      set_type '@J0@' c_bin 'JPEG Image'(c46).
    WHEN 'ZIP' OR 'RAR' OR 'TAR' OR 'GZ' OR 'BZ2'.
      set_type '@12@' c_bin 'Compressed Folder'(c47).
    WHEN 'AVI' OR 'DIVX' OR 'MKV'.
      set_type '@5L@' c_bin 'Video Clip'(c48).
    WHEN 'WAV'.
      set_type '@5L@' c_bin 'Wave Sound'(c49).
    WHEN 'SND'.
      set_type '@5L@' c_bin 'AU Format Sound'(c50).
    WHEN 'MP3'.
      set_type '@5L@' c_bin 'MP3 Format Sound'(c51).
    WHEN 'JAR'.
      set_type '@N5@' c_bin 'Executable Jar File'(c52).
    WHEN 'BAK'.
      set_type '@9V@' c_asc 'BAK File'(c53).
    WHEN 'PRN'.
      set_type_gen '@0X@'.
    WHEN 'TRC' OR 'SAV'.
      set_type_gen '@96@'.
    WHEN 'TMP'.
      set_type_gen '@9D@'.
    WHEN 'HOT'.
      set_type_gen '@9N@'.
    WHEN 'WLG'.
      set_type_gen '@9O@'.
    WHEN 'ECO' OR 'TPP'.
      set_type_gen '@9P@'.
    WHEN 'ORA' OR 'DBA' OR 'SH' OR 'ASP' OR 'CCS' OR 'SC1'.
      set_type_gen '@9U@'.
    WHEN 'SAR'.
      set_type_gen '@9Y@'.
    WHEN 'TPL'.
      set_type_gen '@A7@'.
    WHEN 'PCF' OR 'OUT' OR 'PFB'.
      set_type_gen '@AI@'.
    WHEN 'LST' OR 'DMP' OR 'PKS' OR 'LIB'.
      set_type_gen '@DH@'.
    WHEN 'API' OR 'TP0' OR 'PAR' OR 'TQL' OR 'BCK'.
      set_type_gen '@EQ@'.
    WHEN 'XPM'.
      set_type_gen '@EU@'.
    WHEN 'PRD'.
      set_type_gen '@EW@'.
    WHEN 'ICA'.
      set_type_gen '@GA@'.
    WHEN 'REC'.
      set_type_gen '@I5@'.
    WHEN 'PID' OR 'TAG' OR 'DAT' OR 'MON' OR 'INP' OR 'PFL' OR 'CAR'
      OR 'MSS'.
      set_type_gen '@IF@'.
    WHEN 'PS' OR 'TPS'.
      set_type_gen '@IT@'.
    WHEN 'HTTP'.
      set_type_gen '@IX@'.
    WHEN 'XWD'.
      set_type_gen '@J0@'.
    WHEN 'ELG'.
      set_type_gen '@KK@'.
    WHEN 'BUF'.
      set_type_gen '@NB@'.
    WHEN 'XBM'.
      set_type_gen '@NI@'.
    WHEN 'DEV' OR 'PCI' OR 'SMP' OR 'OPT' OR 'AIX' OR 'EXT'.
      set_type_gen '@O8@'.
    WHEN 'SQL'.
      set_type_gen '@PO@'.
    WHEN OTHERS.
      set_type_gen '@O9@'.
  ENDCASE.

ENDFORM.                    " GET_FILETYPE

*&---------------------------------------------------------------------*
*&      Form  INIT_DETAIL1_ALV
*&---------------------------------------------------------------------*
*       Fill t_fieldcat_grid1, t_sort_grid1, s_layout_grid1
*----------------------------------------------------------------------*
FORM init_detail1_alv.
  DATA: ls_fieldcat TYPE lvc_s_fcat,
        ls_sort     TYPE lvc_s_sort.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'PATH'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '50'.
  ls_fieldcat-lowercase     = abap_true.
  ls_fieldcat-no_out        = abap_true.
  ls_fieldcat-coltext       = 'Path'(h01).                "#EC TEXT_DUP
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'NAME'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '40'.
  ls_fieldcat-lowercase     = abap_true.
  ls_fieldcat-coltext       = 'FileName'(h02).
  ls_fieldcat-col_pos       = 2.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'DIR'.
  ls_fieldcat-datatype      = 'INT4'.
  ls_fieldcat-no_out        = abap_true.
  ls_fieldcat-tech          = abap_true.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'ICON'.
  ls_fieldcat-seltext       = 'Icon'(h03).                "#EC TEXT_DUP
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '2'.
  ls_fieldcat-icon          = abap_true.
  ls_fieldcat-col_pos       = 1.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'FILETYPE'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '16'.
  ls_fieldcat-lowercase     = abap_true.
  ls_fieldcat-coltext       = 'FileType'(h04).
  ls_fieldcat-col_pos       = 3.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'LEN'.
  ls_fieldcat-datatype      = 'INT4'.
  ls_fieldcat-outputlen     = '12'.
  ls_fieldcat-no_zero       = abap_true.
  ls_fieldcat-just          = 'R'.
  ls_fieldcat-coltext       = 'Size'(h05).
  ls_fieldcat-col_pos       = 4.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'CDATE'.
  ls_fieldcat-datatype      = 'DATS'.
  ls_fieldcat-coltext       = 'Creation Date'(h06).
  ls_fieldcat-col_pos       = 5.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'CTIME'.
  ls_fieldcat-datatype      = 'TIMS'.
  ls_fieldcat-coltext       = 'Creation Time'(h07).
  ls_fieldcat-col_pos       = 6.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'MDATE'.
  ls_fieldcat-datatype      = 'DATS'.
  ls_fieldcat-coltext       = 'Modification Date'(h08).
  ls_fieldcat-col_pos       = 7.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'MTIME'.
  ls_fieldcat-datatype      = 'TIMS'.
  ls_fieldcat-coltext       = 'Modification Time'(h09).
  ls_fieldcat-col_pos       = 8.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'RDATE'.
  ls_fieldcat-datatype      = 'DATS'.
  ls_fieldcat-coltext       = 'Access Date'(h10).
  ls_fieldcat-col_pos       = 9.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'RTIME'.
  ls_fieldcat-datatype      = 'TIMS'.
  ls_fieldcat-coltext       = 'Access Time'(h11).
  ls_fieldcat-col_pos       = 10.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'ATTRS'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-coltext       = 'Attributes'(h21).
  ls_fieldcat-col_pos       = 11.
  APPEND ls_fieldcat TO t_fieldcat_grid1.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'FILETRANSFERMODE'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-no_out        = abap_true.
  ls_fieldcat-tech          = abap_true.
  APPEND ls_fieldcat TO t_fieldcat_grid1.

* Default sorting by name (but directory in first)
  CLEAR ls_sort.
  ls_sort-fieldname  = 'DIR'.
  ls_sort-spos       = 1.
  ls_sort-down       = abap_true.
  ls_sort-obligatory = abap_true.
  APPEND ls_sort TO t_sort_grid1.

  CLEAR ls_sort.
  ls_sort-fieldname = 'NAME'.
  ls_sort-spos      = 2.
  ls_sort-up        = abap_true.
  APPEND ls_sort TO t_sort_grid1.

* Default layout
  CLEAR s_layout_grid1.
  s_layout_grid1-no_totline = abap_true.
  s_layout_grid1-no_totarr  = abap_true.
  s_layout_grid1-no_totexp  = abap_true.
  s_layout_grid1-zebra      = abap_true.
  s_layout_grid1-no_toolbar = abap_true.
  s_layout_grid1-sgl_clk_hd = abap_true.
  s_layout_grid1-no_merging = abap_true.
  s_layout_grid1-no_hgridln = abap_true.
  s_layout_grid1-s_dragdrop-row_ddid = w_handle_grid1.
  s_layout_grid1-s_dragdrop-cntr_ddid = w_handle_grid1.

ENDFORM.                    " INIT_DETAIL1_ALV
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID_DISPLAY
*&---------------------------------------------------------------------*
*       Refresh grid display
*----------------------------------------------------------------------*
*      -->PW_gridnumber 1:local grid, 2:remmote grid
*----------------------------------------------------------------------*
FORM refresh_grid_display USING pw_gridnumber TYPE i.
  IF pw_gridnumber = 1.
    CALL METHOD o_grid1->refresh_table_display.
  ELSE.
    CALL METHOD o_grid2->refresh_table_display.

* Add number of files on sum line
    PERFORM overwrite_total_text.
  ENDIF.
ENDFORM.                    " REFRESH_GRID_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  overwrite_total_text
*&---------------------------------------------------------------------*
*       Count number of files in remote dir and display in total line
*----------------------------------------------------------------------*
FORM overwrite_total_text.
  DATA : lo_total TYPE REF TO data,
         ls_detail2 LIKE s_detail2,                         "#EC NEEDED
         lw_count TYPE i.
  FIELD-SYMBOLS : <lt_total> TYPE STANDARD TABLE,
                  <ls_total_line> LIKE s_detail2.

  CALL METHOD o_grid2->get_subtotals
    IMPORTING
      ep_collect00 = lo_total.
  ASSIGN lo_total->* TO <lt_total>.
  IF sy-subrc = 0.
    READ TABLE <lt_total> ASSIGNING <ls_total_line> INDEX 1.
    IF sy-subrc = 0.

* Count number of files of the folder
      LOOP AT t_details2 INTO ls_detail2 WHERE dir = 0.
        lw_count = lw_count + 1.
      ENDLOOP.
      <ls_total_line>-name = lw_count.
      CONDENSE <ls_total_line>-name.
      CONCATENATE <ls_total_line>-name 'files'(m31)
                  INTO <ls_total_line>-name SEPARATED BY space.

* Do a soft refresh grid display without sum recalculation
      CALL METHOD o_grid2->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "overwrite_total_text

*&---------------------------------------------------------------------*
*&      Form  GET_SUB_NODES1
*&---------------------------------------------------------------------*
*       Get all subfolders of a given local PC node
*       Do nothing if node have been already processed (pw_node-read=X)
*----------------------------------------------------------------------*
*      -->PW_NODE       Node to read
*      -->PW_nodeindex  Index in t_nodes1 of the given node
*----------------------------------------------------------------------*
FORM get_sub_nodes1 USING pw_node LIKE s_node
                          pw_nodeindex TYPE i.
  DATA: lt_files TYPE STANDARD TABLE OF file_info,
        ls_file TYPE file_info,
        lt_nodes_new LIKE TABLE OF s_node,
        lw_parent_node LIKE s_node,
        lw_fileupper LIKE ls_file-filename.

  DATA: lw_count TYPE i,
        lw_path_name TYPE string.

* Do not read the folder if previously done
  IF pw_node-read NE space.
    RETURN.
  ENDIF.

  lw_parent_node = pw_node.

  lw_path_name = pw_node-path.
  REFRESH : t_details1, lt_files.

* Get Folders in a Given Directory
  CALL METHOD cl_gui_frontend_services=>directory_list_files
    EXPORTING
      directory                   = lw_path_name
      directories_only            = abap_true
    CHANGING
      file_table                  = lt_files
      count                       = lw_count
    EXCEPTIONS
      cntl_error                  = 1
      directory_list_files_failed = 2
      wrong_parameter             = 3
      error_no_gui                = 4
      not_supported_by_gui        = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  pw_node-read = abap_true.
  MODIFY t_nodes1 FROM pw_node INDEX pw_nodeindex TRANSPORTING read.

  SORT lt_files BY filename.

  LOOP AT lt_files INTO ls_file.
    CLEAR s_node.
    w_node1_count = w_node1_count + 1.
    s_node-node_key = w_node1_count.
    s_node-relatkey = lw_parent_node-node_key.
    s_node-relatship = cl_gui_simple_tree=>relat_last_child.
    s_node-isfolder = abap_true.
    s_node-text = ls_file-filename.
    CONCATENATE lw_parent_node-path ls_file-filename c_local_slash
                INTO s_node-path.
    s_node-texttosort = s_node-text.
    TRANSLATE s_node-texttosort TO LOWER CASE.
* Add trash icon for windows recycle bin entry
    lw_fileupper = ls_file-filename.
    TRANSLATE lw_fileupper TO UPPER CASE.
    IF lw_fileupper = '$RECYCLE.BIN'.
      s_node-n_image = s_node-exp_image = '@11@'.
    ENDIF.
    s_node-dragdropid = w_handle_tree1.
    APPEND s_node TO lt_nodes_new.
  ENDLOOP.
* Sort folder by name (regardless of case)
  SORT lt_nodes_new BY texttosort.
  APPEND LINES OF lt_nodes_new TO t_nodes1.

* Add new nodes
  IF NOT lt_nodes_new IS INITIAL.
    CALL METHOD o_tree1->add_nodes
      EXPORTING
        table_structure_name = 'MTREESNODE'
        node_table           = lt_nodes_new
      EXCEPTIONS
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Open new subfolder tree
    CALL METHOD o_tree1->expand_node
      EXPORTING
        node_key = lw_parent_node-node_key.
  ENDIF.
ENDFORM.                    " GET_SUB_NODES1

*&---------------------------------------------------------------------*
*&      Form  CHANGE_LOCAL_FOLDER
*&---------------------------------------------------------------------*
*       Read Folder of the node
*       - Display subfolders in tree1 (only if not already done)
*       - Read file&subfolders of the folder
*       - Refresh display of grid1
*----------------------------------------------------------------------*
*      -->PW_NODE_KEY  Key node to read
*----------------------------------------------------------------------*
FORM change_local_folder  USING pw_node_key TYPE tv_nodekey.
  DATA lw_index TYPE i.
  DATA ls_node LIKE s_node.

* Avoid trying to open fake ROOT local node
  IF pw_node_key = 'ROOT'.
    RETURN.
  ENDIF.

* Read cannot use binary search option because
* t_node is not sorted on node_key
  READ TABLE t_nodes1 INTO s_node WITH KEY node_key = pw_node_key.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  lw_index = sy-tabix.
  ls_node = s_node.
* Click on a folder get list of sub_nodes for this folder
  PERFORM get_sub_nodes1 USING ls_node lw_index.

* Click on a folder to display content in the grid
  PERFORM get_local_folder_detail USING ls_node-path.

* REFRESH grid1 display
  PERFORM refresh_grid_display USING 1.

* Save change in shared memory
  w_path = ls_node-path.
  EXPORT w_path TO SHARED BUFFER indx(st) ID w_shared_dir_local.
ENDFORM.                    " CHANGE_LOCAL_FOLDER

*&---------------------------------------------------------------------*
*&      Form  INIT_TREE2
*&---------------------------------------------------------------------*
*       Initialize remote tree
*----------------------------------------------------------------------*
FORM init_tree2 .
  DATA: lt_event TYPE cntl_simple_events,
        ls_event TYPE cntl_simple_event,
        lw_effect TYPE i.

* Create a tree control
  CREATE OBJECT o_tree2
    EXPORTING
      parent              = o_container_tree2
      node_selection_mode = cl_gui_simple_tree=>node_sel_mode_single
    EXCEPTIONS
      lifetime_error      = 1
      cntl_system_error   = 2
      create_error        = 3
      failed              = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Catch selection to open folder content
  ls_event-eventid = cl_gui_simple_tree=>eventid_selection_changed.
  ls_event-appl_event = abap_true. " no PAI if event occurs
  APPEND ls_event TO lt_event.

  CALL METHOD o_tree2->set_registered_events
    EXPORTING
      events                    = lt_event
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Assign event handlers in the application class to each desired event
  SET HANDLER o_handle_event->handle_select_remote FOR o_tree2.
  SET HANDLER o_handle_event->handle_remote_tree_drop FOR o_tree2.

* Define drag&drop type allowed (copy and move)
  lw_effect = cl_dragdrop=>move + cl_dragdrop=>copy.
  CREATE OBJECT o_dragdrop_tree2.
  CALL METHOD o_dragdrop_tree2->add
    EXPORTING
      flavor     = 'LINE'
      dragsrc    = space
      droptarget = abap_true
      effect     = lw_effect.
  CALL METHOD o_dragdrop_tree2->get_handle
    IMPORTING
      handle = w_handle_tree2.

* Initialize remote tree content and get server shortcuts
  CLEAR w_node2_count.
  PERFORM init_remote_dir.
ENDFORM.                    " INIT_TREE2

*&---------------------------------------------------------------------*
*&      Form  INIT_REMOTE_DIR
*&---------------------------------------------------------------------*
*       Initialize remote tree content and get server shortcuts
*----------------------------------------------------------------------*
FORM init_remote_dir .
  DATA : lt_drives_remote LIKE t_drives,
         ls_drives_remote LIKE LINE OF lt_drives_remote.

  REFRESH t_nodes2.

* Node with key 'Root'
  CLEAR s_node.
  s_node-node_key = 'ROOT'.
  s_node-isfolder = abap_true.
  s_node-expander = abap_true.
  s_node-text = s_customize-root_name.
  s_node-path = s_customize-root_path.
* For root path, define if it is readable or not
* (readable for unix, not readable for windows)
  IF s_customize-root_path = o_server_command->slash.
    s_node-notreadable = o_server_command->root_not_readable.
  ENDIF.

* For all not except notreadable, allow drop
  IF s_node-notreadable = space.
    s_node-dragdropid = w_handle_tree2.
  ENDIF.
  s_node-n_image = s_node-exp_image = '@6K@'.
  APPEND s_node TO t_nodes2.

* In case of root path is slash, try to scan drives
* Used for windows server only
  IF s_customize-root_path = o_server_command->slash.
    CALL METHOD o_server_command->drive_list
      IMPORTING
        e_drive_table = lt_drives_remote.

    LOOP AT lt_drives_remote INTO ls_drives_remote.
      CLEAR s_node.
      s_node-node_key = ls_drives_remote-drive(1).
      s_node-relatkey = 'ROOT'.
      s_node-relatship = cl_gui_simple_tree=>relat_last_child.
      s_node-isfolder = abap_true.
      s_node-text = ls_drives_remote-desc.
      CASE ls_drives_remote-type.
        WHEN c_drivetypewin_hdd.
          s_node-n_image = s_node-exp_image = '@4V@'.
        WHEN c_drivetypewin_cd.
          s_node-n_image = s_node-exp_image = '@4W@'.
        WHEN c_drivetypewin_remote.
          s_node-n_image = s_node-exp_image = '@53@'.
        WHEN c_drivetypewin_usb.
          s_node-n_image = s_node-exp_image = '@63@'.
        WHEN OTHERS.
      ENDCASE.
      CONCATENATE ls_drives_remote-drive(1) ':\' INTO s_node-path.
      s_node-dragdropid = w_handle_tree2.
      APPEND s_node TO t_nodes2.
    ENDLOOP.
  ENDIF.

* If required, search all logical folders
  IF s_customize-logical_path = abap_true.
    PERFORM add_remote_logical_folders.
  ENDIF.

  CALL METHOD o_tree2->add_nodes
    EXPORTING
      table_structure_name           = 'MTREESNODE'
      node_table                     = t_nodes2
    EXCEPTIONS
      failed                         = 1
      error_in_node_table            = 2
      dp_error                       = 3
      table_structure_name_not_found = 4
      OTHERS                         = 5.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Get custom shortcuts
  PERFORM get_shortcuts.

* Expand the root node to display all drives in the tree
  CALL METHOD o_tree2->expand_root_nodes.
ENDFORM.                    " INIT_REMOTE_DIR

*&---------------------------------------------------------------------*
*&      Form  CHANGE_REMOTE_FOLDER
*&---------------------------------------------------------------------*
*       Read Folder of the node
*       - Display subfolders in tree2 (only if not already done)
*       - Read file&subfolders of the folder
*       - Refresh display of grid2
*----------------------------------------------------------------------*
*      -->PW_NODE_KEY  Key node to read
*----------------------------------------------------------------------*
FORM change_remote_folder USING pw_node_key TYPE tv_nodekey.
  DATA : lw_index TYPE i,
         ls_node LIKE s_node,
         lw_path LIKE s_node-path.

* Read cannot use binary search option because
* t_node is not sorted on node_key
  READ TABLE t_nodes2 INTO ls_node WITH KEY node_key = pw_node_key.
  IF sy-subrc NE 0 OR ls_node-notreadable NE space.
    RETURN.
  ENDIF.

* For logical folders, open shortcut
  IF ls_node-relatkey = 'SHORTCUT'.
    lw_path = ls_node-path+1.
    PERFORM goto_shortcut USING lw_path 2 space.
    RETURN.
  ENDIF.

  lw_index = sy-tabix.
* Click on a folder get list of sub_nodes for this folder
  PERFORM get_sub_nodes2 USING ls_node lw_index.

* Click on a folder to display content in the grid
  PERFORM get_remote_folder_detail USING ls_node-path.

* REFRESH grid2 display
  PERFORM refresh_grid_display USING 2.

* Save change in shared memory
  w_path = ls_node-path.
  EXPORT w_path TO SHARED BUFFER indx(st) ID w_shared_dir_remote.
ENDFORM.                    " CHANGE_REMOTE_FOLDER

*&---------------------------------------------------------------------*
*&      Form  GET_SUB_NODES2
*&---------------------------------------------------------------------*
*       Get all subfolders of a given node
*       Do nothing if node have been already processed (pw_node-read=X)
*----------------------------------------------------------------------*
*      -->PW_NODE       Node to read
*      -->PW_nodeindex  Index in t_nodes2 of the given node
*----------------------------------------------------------------------*
FORM get_sub_nodes2  USING    pw_node LIKE s_node
                              pw_nodeindex TYPE i.
  DATA: ls_parent_node LIKE s_node,
        lt_nodes_new LIKE TABLE OF s_node.
  DATA: BEGIN OF ls_file,
          dirname(75) TYPE c, " name of directory. (possibly truncated.)
          name(75)    TYPE c, " name of entry. (possibly truncated.)
          type(10)    TYPE c, " type of entry.
          len(8)      TYPE p, " length in bytes.
          owner(8)    TYPE c, " owner of the entry.
          mtime(6)    TYPE p, " last modif. date, seconds since 1970
          mode(9)     TYPE c, " like "rwx-r-x--x": protection mode.
          useable(1)  TYPE c,
          subrc(4)    TYPE c,
          errno(3)    TYPE c,
          errmsg(40)  TYPE c,
          mod_date    TYPE d,
          mod_time(8) TYPE c, " hh:mm:ss
          seen(1)     TYPE c,
          changed(1)  TYPE c,
        END OF ls_file,
        lw_fileupper LIKE ls_file-name.
* do not read the folder if previously done
* do not read not readable node
  IF pw_node-read NE space OR pw_node-notreadable NE space.
    RETURN.
  ENDIF.

  ls_parent_node = pw_node.

  pw_node-read = abap_true.
  MODIFY t_nodes2 FROM pw_node INDEX pw_nodeindex TRANSPORTING read.

* Read the folder
  CALL 'C_DIR_READ_START' ID 'DIR'    FIELD ls_parent_node-path
                          ID 'FILE'   FIELD '*'
                          ID 'ERRNO'  FIELD ls_file-errno
                          ID 'ERRMSG' FIELD ls_file-errmsg.

* Cannot read the folder
* Try to close old opened folder and retry to read the folder
* To avoid "Last dir scan has not be finished" error
  IF sy-subrc NE 0 OR ls_file-errmsg NE space.
    CALL 'C_DIR_READ_NEXT'.
    CALL 'C_DIR_READ_FINISH'.
    CALL 'C_DIR_READ_START' ID 'DIR'    FIELD ls_parent_node-path
                            ID 'FILE'   FIELD '*'
                            ID 'ERRNO'  FIELD ls_file-errno
                            ID 'ERRMSG' FIELD ls_file-errmsg.
  ENDIF.

* Cannot read the folder => exit
  IF sy-subrc <> 0 OR ls_file-errmsg NE space.
    MESSAGE s204(s1) WITH sy-subrc 'C_DIR_READ_START'
                          ls_file-errno ls_file-errmsg.
    RETURN.
  ENDIF.
* Read the files
  DO.
    CLEAR ls_file.
    CALL 'C_DIR_READ_NEXT'
      ID 'TYPE'   FIELD ls_file-type
      ID 'NAME'   FIELD ls_file-name
      ID 'LEN'    FIELD ls_file-len
      ID 'OWNER'  FIELD ls_file-owner
      ID 'MTIME'  FIELD ls_file-mtime
      ID 'MODE'   FIELD ls_file-mode
      ID 'ERRNO'  FIELD ls_file-errno
      ID 'ERRMSG' FIELD ls_file-errmsg.
    IF sy-subrc <> 0 AND ls_file-name IS INITIAL.
      EXIT. "exit do
    ENDIF.
* RC=5 File too big to fit in v_file-len
    IF sy-subrc = 5.
      sy-subrc = 0.
    ENDIF.
*   File name returned ?
    CHECK NOT ls_file-name IS INITIAL.
*   Get only dir
    CHECK ls_file-type(4) NE 'file'.
* skip '.' and '..' entries
    CHECK ls_file-name NE '.' AND ls_file-name NE c_goto_parent_dir.

    CLEAR s_node.
    w_node2_count = w_node2_count + 1.
    s_node-node_key = w_node2_count.
    s_node-relatkey = ls_parent_node-node_key.
    s_node-relatship = cl_gui_simple_tree=>relat_last_child.
    s_node-isfolder = abap_true.
    s_node-text = ls_file-name.
    CONCATENATE ls_parent_node-path ls_file-name o_server_command->slash
                INTO s_node-path.
    s_node-texttosort = s_node-text.
    TRANSLATE s_node-texttosort TO LOWER CASE.
* Add trash icon for windows recycle bin entry
    lw_fileupper = ls_file-name.
    TRANSLATE lw_fileupper TO UPPER CASE.
    IF lw_fileupper = '$RECYCLE.BIN'.
      s_node-n_image = s_node-exp_image = '@11@'.
    ENDIF.
    s_node-dragdropid = w_handle_tree2.
    APPEND s_node TO lt_nodes_new.
  ENDDO.
  CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD ls_file-errno
      ID 'ERRMSG' FIELD ls_file-errmsg.

  IF NOT lt_nodes_new IS INITIAL.
* C function give folders unsorted, Sort folder by name
    SORT lt_nodes_new BY texttosort.
    APPEND LINES OF lt_nodes_new TO t_nodes2.

    CALL METHOD o_tree2->add_nodes
      EXPORTING
        table_structure_name = 'MTREESNODE'
        node_table           = lt_nodes_new
      EXCEPTIONS
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Open new subfolder tree
    CALL METHOD o_tree2->expand_node
      EXPORTING
        node_key = ls_parent_node-node_key.
  ENDIF.
ENDFORM.                    " GET_SUB_NODES2

*&---------------------------------------------------------------------*
*&      Form  GET_REMOTE_FOLDER_DETAIL
*&---------------------------------------------------------------------*
*       Get list of files for a given remote path
*       Read the remote folder given and fill t_details2
*----------------------------------------------------------------------*
*      -->PW_PATH  Remote path to read
*----------------------------------------------------------------------*
FORM get_remote_folder_detail USING pw_path TYPE c.
  DATA: BEGIN OF ls_file,
          dirname(75) TYPE c, " name of directory. (possibly truncated.)
          name(75)    TYPE c, " name of entry. (possibly truncated.)
          type(10)    TYPE c, " type of entry.
          len(8)      TYPE p, " length in bytes.
          owner(8)    TYPE c, " owner of the entry.
          mtime(6)    TYPE p, " last modif. date, seconds since 1970
          mode(9)     TYPE c, " like "rwx-r-x--x": protection mode.
          useable(1)  TYPE c,
          subrc(4)    TYPE c,
          errno(3)    TYPE c,
          errmsg(40)  TYPE c,
          mod_date    TYPE d,
          mod_time(8) TYPE c, " hh:mm:ss
          seen(1)     TYPE c,
          changed(1)  TYPE c,
        END OF ls_file,
        lw_fileupper LIKE ls_file-name,
        lw_path LIKE s_detail2-path,
        lw_name TYPE string,
        lw_attrib TYPE string.

  REFRESH t_details2.
  lw_path = pw_path.

* Read the folder
  CALL 'C_DIR_READ_START' ID 'DIR'    FIELD lw_path
                          ID 'FILE'   FIELD '*'
                          ID 'ERRNO'  FIELD ls_file-errno
                          ID 'ERRMSG' FIELD ls_file-errmsg.

* Cannot read the folder
* Try to close old opened folder and retry to read the folder
* To avoid "Last dir scan has not be finished" error
  IF sy-subrc NE 0.
    CALL 'C_DIR_READ_NEXT'.
    CALL 'C_DIR_READ_FINISH'.
    CALL 'C_DIR_READ_START' ID 'DIR'    FIELD lw_path
                            ID 'FILE'   FIELD '*'
                            ID 'ERRNO'  FIELD ls_file-errno
                            ID 'ERRMSG' FIELD ls_file-errmsg.
  ENDIF.

* Cannot read the folder => exit
  IF sy-subrc NE 0.
    MESSAGE ls_file-errmsg TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Read the files
  DO.
    CLEAR ls_file.
    CALL 'C_DIR_READ_NEXT'
      ID 'TYPE'   FIELD ls_file-type
      ID 'NAME'   FIELD ls_file-name
      ID 'LEN'    FIELD ls_file-len
      ID 'OWNER'  FIELD ls_file-owner
      ID 'MTIME'  FIELD ls_file-mtime
      ID 'MODE'   FIELD ls_file-mode
      ID 'ERRNO'  FIELD ls_file-errno
      ID 'ERRMSG' FIELD ls_file-errmsg.
    IF sy-subrc <> 0 AND ls_file-name IS INITIAL.
      EXIT. "exit do
    ENDIF.
* RC=5 File too big to fit in v_file-len
    IF sy-subrc = 5.
      sy-subrc = 0.
    ENDIF.
*   File name returned ?
    CHECK NOT ls_file-name IS INITIAL.

* skip '.' entry
    CHECK ls_file-name NE '.'.
* skip '..' for root node
    IF lw_path = s_customize-root_path.
      CHECK ls_file-name NE c_goto_parent_dir.
    ENDIF.

    CLEAR: s_detail2.
    s_detail2-path = lw_path.
    s_detail2-name = ls_file-name.
* for files, get icon and default transfer mode
    IF ls_file-type(4) = 'file'.
      s_detail2-dir = 0.
      PERFORM get_filetype USING s_detail2-name
                           CHANGING s_detail2-icon
                                    s_detail2-filetype
                                    s_detail2-filetransfermode.
      s_detail2-len = ls_file-len.
    ELSE.
      s_detail2-dir = 1.
      lw_fileupper = ls_file-name.
      TRANSLATE lw_fileupper TO UPPER CASE.
      IF lw_fileupper = '$RECYCLE.BIN'.
        s_detail2-icon = '@11@'.
        s_detail2-filetype = 'Trash bin'(c55).
      ELSE.
        s_detail2-icon = '@IH@'.
        s_detail2-filetype = 'Directory'(c07).
      ENDIF.
* Folder size seem not correct
* s_detail2-len = ls_file-len.

    ENDIF.

* get date/time of last modif from timestamp
    PERFORM timestamp_convert USING ls_file-mtime
                                    s_detail2-mdate
                                    s_detail2-mtime.
    s_detail2-mode = ls_file-mode.
    CONCATENATE s_detail2-path s_detail2-name INTO lw_name.
    lw_name = o_server_command->file_protect( lw_name ).
    CALL METHOD o_server_command->get_attrib
      EXPORTING
        i_file   = lw_name
      IMPORTING
        e_attrib = lw_attrib.

* If auto folder size activated, calculate size of each folder
    IF s_customize-autodirsize = abap_true AND s_detail2-dir = 1
    AND s_detail2-name NE '..' AND s_auth-dirsize NE space.
      s_detail2-len = o_server_command->get_folder_size( lw_name ).
    ENDIF.

    s_detail2-attrs = lw_attrib.
    s_detail2-owner = ls_file-owner.
    APPEND s_detail2 TO t_details2.
  ENDDO.
  CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD ls_file-errno
      ID 'ERRMSG' FIELD ls_file-errmsg.
ENDFORM.                    " GET_REMOTE_FOLDER_DETAIL

*&---------------------------------------------------------------------*
*&      Form  INIT_DETAIL2
*&---------------------------------------------------------------------*
*       Initialize remote grid object
*----------------------------------------------------------------------*
FORM init_detail2 .
  DATA: lw_effect TYPE i.

* Create grid object
  CREATE OBJECT o_grid2
    EXPORTING
      i_parent = o_container_detail2.

* Set all grid event to handle
  SET HANDLER o_handle_event->handle_grid_double_click_remot FOR o_grid2.
  SET HANDLER o_handle_event->handle_grid_context FOR o_grid2.
  SET HANDLER o_handle_event->handle_user_command FOR o_grid2.
  SET HANDLER o_handle_event->handle_toolbar FOR o_grid2.
  SET HANDLER o_handle_event->handle_menu_button FOR o_grid2.
  SET HANDLER o_handle_event->handle_grid_drag FOR o_grid2.
  SET HANDLER o_handle_event->handle_remote_grid_drop FOR o_grid2.

* Define drag&drop type allowed (copy and move)
  lw_effect = cl_dragdrop=>move + cl_dragdrop=>copy.
  CREATE OBJECT o_dragdrop_grid2.
  CALL METHOD o_dragdrop_grid2->add
    EXPORTING
      flavor     = 'LINE'
      dragsrc    = abap_true
      droptarget = abap_true
      effect     = lw_effect.
  CALL METHOD o_dragdrop_grid2->get_handle
    IMPORTING
      handle = w_handle_grid2.

* Fill config ALV var
  PERFORM init_detail2_alv.

* Set the grid config and content
  CALL METHOD o_grid2->set_table_for_first_display
    EXPORTING
      is_layout       = s_layout_grid2
    CHANGING
      it_outtab       = t_details2
      it_fieldcatalog = t_fieldcat_grid2[]
      it_sort         = t_sort_grid2[].

ENDFORM.                    " INIT_DETAIL2

*&---------------------------------------------------------------------*
*&      Form  INIT_DETAIL2_ALV
*&---------------------------------------------------------------------*
*       Fill t_fieldcat_grid2, t_sort_grid2, s_layout_grid2
*----------------------------------------------------------------------*
FORM init_detail2_alv .
  DATA: ls_fieldcat TYPE lvc_s_fcat,
        ls_sort     TYPE lvc_s_sort.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'PATH'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '50'.
  ls_fieldcat-lowercase     = abap_true.
  ls_fieldcat-no_out        = abap_true.
  ls_fieldcat-coltext       = 'Path'(h01).                "#EC TEXT_DUP
  APPEND ls_fieldcat TO t_fieldcat_grid2.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'NAME'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '40'.
  ls_fieldcat-lowercase     = abap_true.
  ls_fieldcat-coltext       = 'FileName'(h02).
  ls_fieldcat-col_pos       = 2.
  APPEND ls_fieldcat TO  t_fieldcat_grid2.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'DIR'.
  ls_fieldcat-datatype      = 'INT4'.
  ls_fieldcat-no_out        = abap_true.
  ls_fieldcat-tech          = abap_true.
  APPEND ls_fieldcat TO t_fieldcat_grid2.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'ICON'.
  ls_fieldcat-seltext       = 'Icon'(h03).                "#EC TEXT_DUP
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '2'.
  ls_fieldcat-icon          = abap_true.
  ls_fieldcat-col_pos       = 1.
  APPEND ls_fieldcat TO t_fieldcat_grid2.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'FILETYPE'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '16'.
  ls_fieldcat-lowercase     = abap_true.
  ls_fieldcat-coltext       = 'FileType'(h04).
  ls_fieldcat-col_pos       = 3.
  APPEND ls_fieldcat TO t_fieldcat_grid2.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'LEN'.
  ls_fieldcat-datatype      = 'INT4'.
  ls_fieldcat-outputlen     = '12'.
  ls_fieldcat-no_zero       = abap_true.
  ls_fieldcat-just          = 'R'.
  ls_fieldcat-coltext       = 'Size'(h05).
  ls_fieldcat-do_sum        = abap_true.
  ls_fieldcat-col_pos       = 4.
  APPEND ls_fieldcat TO t_fieldcat_grid2.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'MDATE'.
  ls_fieldcat-datatype      = 'DATS'.
  ls_fieldcat-coltext       = 'Modification Date'(h08).
  ls_fieldcat-col_pos       = 5.
  APPEND ls_fieldcat TO t_fieldcat_grid2.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'MTIME'.
  ls_fieldcat-datatype      = 'TIMS'.
  ls_fieldcat-coltext       = 'Modification Time'(h09).
  ls_fieldcat-col_pos       = 6.
  APPEND ls_fieldcat TO t_fieldcat_grid2.
  IF o_server_command->attrib_mode = lif_server_command=>c_attrmode_chmod.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname     = 'MODE'.
    ls_fieldcat-datatype      = 'CHAR'.
    ls_fieldcat-outputlen     = '5'.
    ls_fieldcat-coltext       = 'Mode'(h12).
    ls_fieldcat-col_pos       = 7.
    APPEND ls_fieldcat TO t_fieldcat_grid2.
  ELSEIF o_server_command->attrib_mode = lif_server_command=>c_attrmode_attrib.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname     = 'ATTRS'.
    ls_fieldcat-datatype      = 'CHAR'.
    ls_fieldcat-outputlen     = '10'.
    ls_fieldcat-coltext       = 'Attributes'(h21).
    ls_fieldcat-col_pos       = 7.
    APPEND ls_fieldcat TO t_fieldcat_grid2.
  ENDIF.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'OWNER'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-outputlen     = '20'.
  ls_fieldcat-coltext       = 'Owner'(h18).
  ls_fieldcat-col_pos       = 8.
  APPEND ls_fieldcat TO t_fieldcat_grid2.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'FILETRANSFERMODE'.
  ls_fieldcat-datatype      = 'CHAR'.
  ls_fieldcat-no_out        = abap_true.
  ls_fieldcat-tech          = abap_true.
  APPEND ls_fieldcat TO t_fieldcat_grid2.

* Default sorting by name (but directory in first)
  CLEAR ls_sort.
  ls_sort-fieldname  = 'DIR'.
  ls_sort-spos       = 1.
  ls_sort-down       = abap_true.
  ls_sort-obligatory = abap_true.
  APPEND ls_sort TO t_sort_grid2.

  CLEAR ls_sort.
  ls_sort-fieldname = 'NAME'.
  ls_sort-spos      = 2.
  ls_sort-up        = abap_true.
  APPEND ls_sort TO t_sort_grid2.

* Default layout
  CLEAR s_layout_grid2.
  s_layout_grid2-no_totline = space.
  s_layout_grid2-no_totarr  = abap_true.
  s_layout_grid2-no_totexp  = abap_true.
  s_layout_grid2-zebra      = abap_true.
  s_layout_grid2-sgl_clk_hd = abap_true.
  s_layout_grid2-no_merging = abap_true.
  s_layout_grid2-no_hgridln = abap_true.
  s_layout_grid2-s_dragdrop-row_ddid = w_handle_grid2.
  s_layout_grid2-s_dragdrop-cntr_ddid = w_handle_grid2.
  s_layout_grid2-totals_bef = s_customize-total_on_top.

ENDFORM.                    " INIT_DETAIL2_ALV

*&---------------------------------------------------------------------*
*&      Form  SAVE_REMOTE_TO_LOCAL
*&---------------------------------------------------------------------*
*       Download remote file to local PC
*       If no local path given, read TMP directory
*----------------------------------------------------------------------*
*      -->PW_REMOTE_PATH  Remote path
*      -->PW_REMOTE_NAME  Remote name
*      -->PW_LOCAL_PATH   Local path
*      -->PW_LOCAL_NAME   Local name
*      -->PW_TRANSFERMODE Transfer mode
*      -->PW_OPEN         Open downloaded file : yes / no / as
*----------------------------------------------------------------------*
FORM save_remote_to_local  USING pw_remote_path TYPE c
                                 pw_remote_name TYPE c
                                 pw_local_path TYPE c
                                 pw_local_name TYPE c
                                 pw_transfermode TYPE c
                                 pw_open TYPE c.
  DATA : lw_localdir TYPE string.
  DATA : lw_local_path(1000) TYPE c,
         lw_file(1000) TYPE c,
         ls_file TYPE string,
         lt_file LIKE TABLE OF ls_file,
         ls_file_bin(1000) TYPE x,
         lt_file_bin LIKE TABLE OF ls_file_bin,
         lw_filetype(10) TYPE c,
         lw_string TYPE string,
         lw_string2 TYPE string,
         lw_action(1) TYPE c,
         lw_len TYPE i,
         lw_filelength TYPE i,
         lw_replace TYPE string,
         lw_return TYPE abap_bool.
  FIELD-SYMBOLS: <lt_file> TYPE STANDARD TABLE,
                 <ls_file> TYPE any.

* Authority check to download files
  IF s_auth-download NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* If local path not given, get TEMP path
  IF pw_local_path IS INITIAL.
    CALL METHOD cl_gui_frontend_services=>get_temp_directory
      CHANGING
        temp_dir             = lw_localdir
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Cannot read tmp directory'(e07) TYPE c_msg_success
              DISPLAY LIKE c_msg_error.
      RETURN.
    ENDIF.
    CALL METHOD cl_gui_cfw=>flush.
  ELSE.
    lw_localdir = pw_local_path.
  ENDIF.
  IF lw_localdir IS INITIAL.
    MESSAGE 'Cannot read tmp directory'(e07) TYPE c_msg_success
            DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* add \ at end of path if necessary
  lw_local_path = lw_localdir.
  lw_len = strlen( lw_local_path ).
  lw_len = lw_len - 1.
  IF lw_local_path+lw_len(1) NE c_local_slash.
    CONCATENATE lw_localdir c_local_slash INTO lw_localdir.
  ENDIF.

* Define transfer mode.
  IF w_force_transfer_mode IS INITIAL.
    lw_filetype = pw_transfermode.
  ELSE.
    lw_filetype = w_force_transfer_mode.
  ENDIF.

  CONCATENATE pw_remote_path pw_remote_name INTO lw_file.

* Confirm action on remote server (except for hidden download)
  IF pw_open = c_open_no.
    CONCATENATE lw_localdir pw_local_name INTO ls_file.
    CALL METHOD cl_gui_frontend_services=>file_exist
      EXPORTING
        file   = ls_file
      RECEIVING
        result = lw_return
      EXCEPTIONS
        OTHERS = 5.
    IF sy-subrc = 0 AND lw_return = abap_true.
      lw_string = 'File # already exists in #. Overwrite ?'(t22).
      lw_string2 = 'Overwrite'(t23).
    ELSE.
      lw_string = 'Download # to # ?'(t14).
      lw_string2 = 'Download'(t24).
    ENDIF.
* In case of configuration of silent download, display
* confirmation only for overwrite
    IF s_customize-confirm_dl = abap_true
    OR lw_string2 = 'Overwrite'(t23).
      lw_replace = lw_file.
      lw_replace = o_server_command->file_protect( lw_replace ).
      REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string
              WITH lw_replace.
      lw_replace = o_server_command->file_protect( lw_localdir ).
      REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string
              WITH lw_replace.
      PERFORM confirm_action USING lw_string lw_string2
                             CHANGING lw_action.
      IF lw_action = space.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.
  CONCATENATE lw_localdir pw_local_name INTO lw_localdir.

* Read remote file
  IF lw_filetype = c_bin.
* Use hexa table for binary transfer     @Thoul
    ASSIGN lt_file_bin TO <lt_file>.
    ASSIGN ls_file_bin TO <ls_file>.
    IF NOT <lt_file> IS ASSIGNED
    OR NOT <ls_file> IS ASSIGNED. "may not append
      RETURN.
    ENDIF.
* Open in binary mode
    OPEN DATASET lw_file FOR INPUT IN BINARY MODE.
  ELSE.
* Use string table for text transfer
    ASSIGN lt_file TO <lt_file>.
    ASSIGN ls_file TO <ls_file>.
    IF NOT <lt_file> IS ASSIGNED
    OR NOT <ls_file> IS ASSIGNED. "may not append
      RETURN.
    ENDIF.
* Open in text mode
    OPEN DATASET lw_file FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.
  ENDIF.
  IF sy-subrc <> 0.
    MESSAGE 'Cannot read remote file'(e09) TYPE c_msg_success
            DISPLAY LIKE c_msg_error.
    RETURN.
  ELSE.
    CLEAR lw_filelength.
    DO.
      READ DATASET lw_file INTO <ls_file> LENGTH lw_len.
      IF sy-subrc = 0.
        APPEND <ls_file> TO <lt_file>.
        lw_filelength = lw_filelength + lw_len.
      ELSEIF sy-subrc = 4.
        IF NOT <ls_file> IS INITIAL.
          APPEND <ls_file> TO <lt_file>.
          lw_filelength = lw_filelength + lw_len.
        ENDIF.
        EXIT. "exit do
      ENDIF.
    ENDDO.
    CLOSE DATASET lw_file.
  ENDIF.

  IF lw_filetype NE c_bin.
    CLEAR lw_filelength.
  ENDIF.

* Save remote file to local dir
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lw_localdir
      filetype                = lw_filetype
      confirm_overwrite       = space
      bin_filesize            = lw_filelength
    CHANGING
      data_tab                = <lt_file>
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc NE 0.
    MESSAGE 'Cannot create local file'(e11) TYPE c_msg_success
            DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.
  FREE <lt_file>.

* Open local file if required
  IF pw_open = c_open_yes.
    CALL METHOD cl_gui_frontend_services=>execute
      EXPORTING
        document               = lw_localdir
      EXCEPTIONS
        cntl_error             = 1
        error_no_gui           = 2
        bad_parameter          = 3
        file_not_found         = 4
        path_not_found         = 5
        file_extension_unknown = 6
        error_execute_failed   = 7
        synchronous_failed     = 8
        not_supported_by_gui   = 9
        OTHERS                 = 10.
    IF sy-subrc <> 0.
      MESSAGE 'Cannot open the local file/folder'(e27)
              TYPE c_msg_success DISPLAY LIKE c_msg_error.
    ENDIF.
  ELSEIF pw_open = c_open_as.
    CONCATENATE 'SHELL32.DLL,OpenAs_RunDLL' lw_localdir
                INTO lw_localdir SEPARATED BY space.
    CALL METHOD cl_gui_frontend_services=>execute
      EXPORTING
        application            = 'RUNDLL32.EXE'
        parameter              = lw_localdir
      EXCEPTIONS
        cntl_error             = 1
        error_no_gui           = 2
        bad_parameter          = 3
        file_not_found         = 4
        path_not_found         = 5
        file_extension_unknown = 6
        error_execute_failed   = 7
        synchronous_failed     = 8
        not_supported_by_gui   = 9
        OTHERS                 = 10.
    IF sy-subrc <> 0.
      MESSAGE 'Cannot open the local file/folder'(e27)
              TYPE c_msg_success DISPLAY LIKE c_msg_error.
    ENDIF.
  ELSE.
    o_server_command->commit( ).
  ENDIF.

ENDFORM.                    " SAVE_REMOTE_TO_LOCAL

*&---------------------------------------------------------------------*
*&      Form  compress_item
*&---------------------------------------------------------------------*
*       Compress given file/folder.
*       The compressed file have the same name with compression
*       extension (depend of server : .tar.bz2 or .zip)
*----------------------------------------------------------------------*
*      -->PW_NAME     Path+Name of the file to compress
*----------------------------------------------------------------------*
FORM compress_item USING pw_name TYPE c.
  DATA : lw_name TYPE string,
         lw_string TYPE string,
         lw_action(1) TYPE c.

* Authority check for compress files
  IF s_auth-zip NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  lw_name = pw_name.
  lw_name = o_server_command->file_protect( lw_name ).

* Confirm action on remote server
  lw_string = 'Compress # ?'(t13).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  PERFORM confirm_action USING lw_string 'Compress'(t27) CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Server command to compress
* Method depend of server tar+bz2 for AIX, zip for windows
  lw_name = pw_name.
  CALL METHOD o_server_command->compress
    EXPORTING
      i_file = lw_name. "send file name unprotected

  o_server_command->commit( ).
ENDFORM.                    "compress_item

*&---------------------------------------------------------------------*
*&      Form  DELETE_FILE
*&---------------------------------------------------------------------*
*       Delete remote file
*----------------------------------------------------------------------*
*      -->PW_NAME  Path+name of the remote file
*----------------------------------------------------------------------*
FORM delete_file USING pw_name TYPE c.
  DATA : lw_string TYPE string,
         lw_action(1) TYPE c,
         lw_name TYPE string.

* Authority check to delete files
  IF s_auth-delete_file NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  lw_name = pw_name.
  lw_name = o_server_command->file_protect( lw_name ).

* Confirm action on remote server
  lw_string = 'Delete file # ?'(t12).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  PERFORM confirm_action USING lw_string 'Delete'(t26) CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Server command to delete file
  CALL METHOD o_server_command->delete
    EXPORTING
      i_source = lw_name
      i_mode   = lif_server_command=>c_copymode_file.

  o_server_command->commit( ).
ENDFORM.                    " DELETE_FILE

*&---------------------------------------------------------------------*
*&      Form  DELETE_FOLDER
*&---------------------------------------------------------------------*
*       Delete remote folder
*----------------------------------------------------------------------*
*      -->PW_TARGET  Remote folder to delete
*----------------------------------------------------------------------*
FORM delete_folder USING pw_target TYPE c.
  DATA : lw_string TYPE string,
         lw_action(1) TYPE c,
         lw_name TYPE string.

* Authority check to delete folders
  IF s_auth-delete_folder NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  lw_name = pw_target.
  lw_name = o_server_command->file_protect( lw_name ).

* Confirm action on remote server
  lw_string = 'Delete folder # and all there content ?'(t11).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  PERFORM confirm_action USING lw_string 'Delete'(t26) CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Server command to delete folder
  CALL METHOD o_server_command->delete
    EXPORTING
      i_source = lw_name
      i_mode   = lif_server_command=>c_copymode_folder.

  o_server_command->commit( ).
ENDFORM.                    " DELETE_FOLDER

*&---------------------------------------------------------------------*
*&      Form  confirm_action
*&---------------------------------------------------------------------*
*       Display a popup to confirm all server action
*----------------------------------------------------------------------*
*      -->PW_TEXT    text of the popup
*      -->PW_OK      Continue = 'X', space to cancel
*----------------------------------------------------------------------*
FORM confirm_action USING pw_text TYPE string
                          pw_btn1 TYPE string
                    CHANGING pw_ok TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Warning : critical operation'(t10)
      text_question         = pw_text
      default_button        = '2'
      display_cancel_button = space
      text_button_1         = pw_btn1
      icon_button_1         = '@01@'
      text_button_2         = 'Cancel'(t36)
      icon_button_2         = '@02@'
    IMPORTING
      answer                = pw_ok
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0 OR pw_ok NE 1.
    CLEAR pw_ok.
    MESSAGE 'Action cancelled'(e12) TYPE c_msg_success
            DISPLAY LIKE c_msg_error.
  ELSE.
    pw_ok = abap_true.
  ENDIF.
ENDFORM.                    "confirm_action

*&---------------------------------------------------------------------*
*&      Form  GOTO_SHORTCUT
*&---------------------------------------------------------------------*
*       Open the remote given path
*----------------------------------------------------------------------*
*      -->PW_PATH Remote Path to open
*      -->PW_TYPE 0=paste path, 1=shortcut, 2=other (no auth check)
*      -->PW_DONOTOPEN If X, just add into tree
*----------------------------------------------------------------------*
FORM goto_shortcut USING pw_path TYPE c
                         pw_type TYPE i
                         pw_donotopen TYPE c.
  DATA : ls_folder(500) TYPE c,
         lt_folders LIKE TABLE OF ls_folder,
         ls_current_node LIKE s_node,
         lw_new_path LIKE s_node-path,
         lw_current_index TYPE i.

* Authority check for shortcut use
  IF s_auth-shortcut NE abap_true AND pw_type = 1.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Authority check for paste path (already done, may not append)
  IF s_auth-paste_path NE abap_true AND pw_type = 0.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Check that shortcut is in the restricted user path
  IF s_customize-root_path_len > 1
  AND pw_path(s_customize-root_path_len) NE s_customize-root_path.
    RETURN.
  ENDIF.

  IF s_customize-root_path_len > 1.
    SPLIT pw_path+s_customize-root_path_len AT o_server_command->slash INTO TABLE lt_folders.
  ELSEIF pw_path(1) = o_server_command->slash AND pw_path+1(1) = o_server_command->slash.
* Manage special case of path to a different server
* Only in case of root access allowed
    SPLIT pw_path+2 AT o_server_command->slash INTO TABLE lt_folders.
    READ TABLE lt_folders INTO ls_folder INDEX 1.
    CONCATENATE o_server_command->slash o_server_command->slash ls_folder
               INTO ls_folder.
    MODIFY lt_folders FROM ls_folder INDEX 1.

* Create server root node if not exists
    CONCATENATE ls_folder o_server_command->slash INTO lw_new_path.
    READ TABLE t_nodes2 TRANSPORTING NO FIELDS WITH KEY path = lw_new_path.
    IF sy-subrc NE 0.
      CLEAR ls_current_node.
      PERFORM add_new_server_remote USING ls_folder ls_current_node.
    ENDIF.
  ELSE.
    SPLIT pw_path AT o_server_command->slash INTO TABLE lt_folders.
  ENDIF.

  READ TABLE t_nodes2 INTO s_node INDEX 1.
  ls_current_node = s_node.
  lw_current_index = 1.

* For not readable node or distant server, root path is not convenient
* Start with empty path
  IF ls_current_node-notreadable NE space
  OR ( pw_path(1) = o_server_command->slash AND pw_path+1(1) = o_server_command->slash
       AND s_customize-root_path_len LE 1 ).
    CLEAR ls_current_node-path.
  ENDIF.

* Fly to all folder that compose the given path and load them in the
* tree if necessary
  LOOP AT lt_folders INTO ls_folder.
    CHECK NOT ls_folder IS INITIAL.

    CONCATENATE ls_current_node-path ls_folder o_server_command->slash
                INTO lw_new_path.
    READ TABLE t_nodes2 INTO s_node WITH KEY path = lw_new_path.
    IF sy-subrc NE 0.
      PERFORM get_sub_nodes2 USING ls_current_node lw_current_index.
      READ TABLE t_nodes2 INTO s_node WITH KEY path = lw_new_path.
    ENDIF.
* Special case of external server
* May have access to subfolder but not to root
* Create manualy all subfolder if no access
    IF sy-subrc NE 0 AND pw_path(1) = o_server_command->slash
    AND pw_path+1(1) = o_server_command->slash
    AND s_customize-root_path_len LE 1.
      PERFORM add_new_server_remote USING ls_folder ls_current_node.
      READ TABLE t_nodes2 INTO s_node WITH KEY path = lw_new_path.
    ENDIF.
    IF sy-subrc = 0.
      ls_current_node = s_node.
      lw_current_index = sy-tabix.
    ELSE.
      EXIT. "exit loop
    ENDIF.
  ENDLOOP.

* If donotload active : exit
  IF pw_donotopen NE space.
    RETURN.
  ENDIF.

* Load given folder
  PERFORM change_remote_folder USING ls_current_node-node_key.

* Set focus in tree on the current folder
  CALL METHOD o_tree2->set_selected_node
    EXPORTING
      node_key = ls_current_node-node_key.

* Scroll the tree to set the current folder at the top of tree window
  CALL METHOD o_tree2->set_top_node
    EXPORTING
      node_key = ls_current_node-node_key.

ENDFORM.                    " GOTO_SHORTCUT

*&---------------------------------------------------------------------*
*&      Form  GOTO_SHORTCUT_LOCAL
*&---------------------------------------------------------------------*
*       Open the local given path
*----------------------------------------------------------------------*
*      -->PW_PATH Local Path to open
*----------------------------------------------------------------------*
FORM goto_shortcut_local USING pw_path TYPE c.
  DATA : BEGIN OF ls_folder,
           value(500) TYPE c,
         END OF ls_folder,
         lt_folders LIKE TABLE OF ls_folder,
         ls_current_node LIKE s_node,
         lw_new_path LIKE s_node-path,
         lw_current_index TYPE i.

* Search if node already catched
  READ TABLE t_nodes1 INTO s_node WITH KEY path = pw_path.
  IF sy-subrc = 0.
    ls_current_node = s_node.
  ELSE.
* fly to all folder that compose the given path and load them in the
* tree if necessary

    SPLIT pw_path AT c_local_slash INTO TABLE lt_folders.
    DELETE lt_folders WHERE value IS INITIAL.

* Read ROOT node
    READ TABLE t_nodes1 INTO s_node INDEX 1.
    ls_current_node = s_node.
    lw_current_index = 1.

    LOOP AT lt_folders INTO ls_folder.
      CONCATENATE ls_current_node-path ls_folder c_local_slash
                  INTO lw_new_path.
      READ TABLE t_nodes1 INTO s_node WITH KEY path = lw_new_path.
      IF sy-subrc NE 0.
        PERFORM get_sub_nodes1 USING ls_current_node lw_current_index.
        READ TABLE t_nodes1 INTO s_node WITH KEY path = lw_new_path.
      ENDIF.
      IF sy-subrc = 0.
        ls_current_node = s_node.
        lw_current_index = sy-tabix.
      ELSE.
        EXIT. "exit loop
      ENDIF.
    ENDLOOP.
  ENDIF.

* Load given folder
  PERFORM change_local_folder USING ls_current_node-node_key.

* Set focus in tree on the current folder
  CALL METHOD o_tree1->set_selected_node
    EXPORTING
      node_key = ls_current_node-node_key.

* Scroll the tree to set the current folder at the top of tree window
  CALL METHOD o_tree1->set_top_node
    EXPORTING
      node_key = ls_current_node-node_key.

ENDFORM.                    " GOTO_SHORTCUT_LOCAL

*&---------------------------------------------------------------------*
*&      Form  CREATE_FOLDER
*&---------------------------------------------------------------------*
*       Create a folder named "newfolder" on the remote server
*----------------------------------------------------------------------*
*      -->PW_PATH  Path where new folder will be created
*----------------------------------------------------------------------*
FORM create_folder USING pw_path TYPE c.
  DATA : lw_string TYPE string,
         lw_action(1) TYPE c,
         ls_field TYPE sval,
         lt_fields LIKE TABLE OF ls_field,
         lw_name TYPE string.

* Authority check for folder creation
  IF s_auth-create_folder NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Ask new name
  ls_field-tabname = 'DXFILE'.
  ls_field-fieldname = 'FILENAME'.
  ls_field-field_obl = abap_true.
  ls_field-value = 'newfolder'(h31).
  APPEND ls_field TO lt_fields.
  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title = 'Enter new folder name'(t19)
    TABLES
      fields      = lt_fields
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc <> 0.
    MESSAGE 'Action cancelled'(e12) TYPE c_msg_success
        DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Control that new name has only allowed char
  READ TABLE lt_fields INTO ls_field INDEX 1.
  lw_string = ls_field-value.
  TRANSLATE lw_string TO UPPER CASE.
  IF ls_field-value IS INITIAL
  OR NOT lw_string CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-+.'.
    MESSAGE 'Forbidden character, operation cancelled'(e16)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  CONCATENATE pw_path ls_field-value INTO lw_name.
  lw_name = o_server_command->file_protect( lw_name ).

* Confirm action on remote server
  lw_string = 'Create folder # ?'(t09).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  PERFORM confirm_action USING lw_string 'Create'(t28) CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Server command to create folder
  CALL METHOD o_server_command->create_folder
    EXPORTING
      i_newfolder = lw_name.

  o_server_command->commit( ).
ENDFORM.                    " CREATE_FOLDER

*&---------------------------------------------------------------------*
*&      Form  CLIPBOARD_EXPORT
*&---------------------------------------------------------------------*
*       Export file name to clipboard
*----------------------------------------------------------------------*
*      -->PW_NAME path+name of the file to export
*      -->PW_TYPE 0=local path, 1=remote path
*----------------------------------------------------------------------*
FORM clipboard_export USING pw_name TYPE c pw_type TYPE i.
  DATA : lw_rc TYPE i,
         ls_data(1000) TYPE c,
         lt_data LIKE TABLE OF ls_data.                     "#EC NEEDED

* Authority check for copy remote path
  IF s_auth-copy_path NE abap_true AND pw_type = 1.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  ls_data = pw_name.
  APPEND ls_data TO lt_data.

  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data = lt_data
    CHANGING
      rc   = lw_rc.

  MESSAGE 'Path sent to clipbard'(t08) TYPE c_msg_success.

ENDFORM.                    " CLIPBOARD_EXPORT

*&---------------------------------------------------------------------*
*&      Form  CLIPBOARD_IMPORT
*&---------------------------------------------------------------------*
*       Open the remote path stored in clipboard
*----------------------------------------------------------------------*
FORM clipboard_import.
  DATA: ls_data(1000) TYPE c,
        lt_data LIKE TABLE OF ls_data,
        lw_string TYPE string.

* Authority check for paste path
  IF s_auth-paste_path NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Import clipboard in memory
  CALL METHOD cl_gui_frontend_services=>clipboard_import
    IMPORTING
      data = lt_data.
  READ TABLE lt_data INTO ls_data INDEX 1.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

* Check that shortcut is in the restricted user path
  IF s_customize-root_path_len > 1
  AND ls_data(s_customize-root_path_len) NE s_customize-root_path.
    MESSAGE 'Clipboard content is not a valid path'(e14)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Verify clipboard content : No space or special character
  lw_string = ls_data.
  TRANSLATE lw_string TO UPPER CASE.
  IF NOT lw_string CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-+./\:'.
    MESSAGE 'Clipboard content is not a valid path'(e14)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Open remote folder
  PERFORM goto_shortcut USING ls_data 0 space.

ENDFORM.                    " CLIPBOARD_IMPORT

*&---------------------------------------------------------------------*
*&      Form  DUPLICATE_ITEM
*&---------------------------------------------------------------------*
*       Duplicate file or folder (add _copy at the end of the name)
*----------------------------------------------------------------------*
*      -->PW_NAME  Path+Name of the file to duplicate
*      -->PW_TYPE  0=file, 1=folder
*----------------------------------------------------------------------*
FORM duplicate_item USING pw_name TYPE c
                          pw_type TYPE i.
  DATA lw_pos TYPE i.
  DATA : lw_string TYPE string,
         lw_action(1) TYPE c,
         lw_name TYPE string,
         lw_name_source TYPE string.

* Authority check to duplicate files
  IF s_auth-duplicate_file NE abap_true AND pw_type = 0.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Authority check to duplicate folders
  IF s_auth-duplicate_folder NE abap_true AND pw_type = 1.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  find_last_occurrence '.'  pw_name lw_pos.

* find name for copy
  lw_name = pw_name.
  DO.
    IF sy-index > 5.
      MESSAGE 'Too many copy exists. Delete or rename old copies'(e15)
              TYPE c_msg_success DISPLAY LIKE c_msg_error.
      CLEAR lw_name.
      EXIT. "exit do
    ENDIF.
    IF lw_pos NE 0. "file
      CONCATENATE lw_name(lw_pos) '_copy' lw_name+lw_pos INTO lw_name.
    ELSE. "folder or file without extension
      CONCATENATE lw_name '_copy' INTO lw_name.
    ENDIF.
    OPEN DATASET lw_name FOR INPUT IN BINARY MODE.
    IF sy-subrc EQ 8. "file does not exist, use
      EXIT. "exit do
    ENDIF.
    CLOSE DATASET lw_name.
  ENDDO.
  IF lw_name IS INITIAL.
    RETURN.
  ENDIF.

  lw_name_source = pw_name.
  lw_name_source = o_server_command->file_protect( lw_name_source ).
  lw_name = o_server_command->file_protect( lw_name ).

* Confirm action on remote server
  lw_string = 'Duplicate # to # ?'(t07).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string
                           WITH lw_name_source.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  PERFORM confirm_action USING lw_string 'Duplicate'(t29)
                         CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Server command to copy file/folder
  IF pw_type = 0. "file
    CALL METHOD o_server_command->copy
      EXPORTING
        i_source = lw_name_source
        i_target = lw_name
        i_mode   = lif_server_command=>c_copymode_file.
  ELSE.
    CALL METHOD o_server_command->copy
      EXPORTING
        i_source = lw_name_source
        i_target = lw_name
        i_mode   = lif_server_command=>c_copymode_folder.
  ENDIF.

  o_server_command->commit( ).
ENDFORM.                    " DUPLICATE_ITEM

*&---------------------------------------------------------------------*
*&      Form  REFRESH_TREE2
*&---------------------------------------------------------------------*
*       Refresh the given node :
*       - Delete all childs (and subchilds) of the node
*       - Rebuild node
*       - Rebuild grid for this node
*       - Refresh grid display
*----------------------------------------------------------------------*
*      -->PW_NODE  Node to refresh
*----------------------------------------------------------------------*
FORM refresh_tree2 USING pw_node LIKE s_node.
  DATA lw_index TYPE i.
  DATA : lw_deleted(1) TYPE c,
         ls_node LIKE s_node.

* delete direct childs
  DELETE t_nodes2 WHERE relatkey = pw_node-node_key.

* delete childs of the childs
  lw_deleted = abap_true.
  WHILE lw_deleted = abap_true.
    CLEAR lw_deleted.
    LOOP AT t_nodes2 INTO ls_node WHERE NOT relatkey IS INITIAL.
      lw_index = sy-tabix.
* for each node, check if parent exist
      READ TABLE t_nodes2 WITH KEY node_key = ls_node-relatkey
                 TRANSPORTING NO FIELDS.
* if parent not exist, delete node
      IF sy-subrc NE 0.
        DELETE t_nodes2 INDEX lw_index.
        lw_deleted = abap_true.
        CONTINUE.
      ENDIF.
    ENDLOOP.
* redo the process if at least 1 node is deleted
  ENDWHILE.
  READ TABLE t_nodes2 INTO ls_node
             WITH KEY node_key = pw_node-node_key.
  lw_index = sy-tabix.
  CLEAR ls_node-read.
  MODIFY t_nodes2 FROM ls_node INDEX lw_index TRANSPORTING read.

* delete all nodes in the tree control
  CALL METHOD o_tree2->delete_all_nodes.

* Rebuild nodes from tree data table
  CALL METHOD o_tree2->add_nodes
    EXPORTING
      node_table           = t_nodes2
      table_structure_name = 'MTREESNODE'.
  CALL METHOD cl_gui_cfw=>flush.

* rebuild given node
  PERFORM change_remote_folder USING ls_node-node_key.

* set tree focus on given node
  CALL METHOD o_tree2->set_selected_node
    EXPORTING
      node_key = ls_node-node_key.

* scrool until given node
  CALL METHOD o_tree2->set_top_node
    EXPORTING
      node_key = ls_node-node_key.

ENDFORM.                    " REFRESH_TREE2

*&---------------------------------------------------------------------*
*&      Form  RENAME_ITEM
*&---------------------------------------------------------------------*
*       Rename file / folder
*----------------------------------------------------------------------*
*      -->PW_PATH  Path of the file to rename
*      -->PW_NAME  Name of the file to rename
*      -->PW_TYPE  0=file, 1=folder
*----------------------------------------------------------------------*
FORM rename_item  USING pw_path TYPE c
                        pw_name TYPE c
                        pw_type TYPE i.
  DATA : lw_name LIKE s_node-path,
         lw_source TYPE string,
         lw_target TYPE string,
         ls_field TYPE sval,
         lt_fields LIKE TABLE OF ls_field,
         lw_action(1) TYPE c,
         lw_string TYPE string.

* Authority check for renaming files
  IF s_auth-rename_file NE abap_true AND pw_type = 0.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Authority check for renaming folders
  IF s_auth-rename_folder NE abap_true AND pw_type = 1.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Ask new name
  lw_name = pw_name.
  ls_field-tabname = 'DXFILE'.
  ls_field-fieldname = 'FILENAME'.
  ls_field-field_obl = abap_true.
  ls_field-value = pw_name.
  APPEND ls_field TO lt_fields.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title = 'Enter new name'(t06)
    TABLES
      fields      = lt_fields
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  READ TABLE lt_fields INTO ls_field INDEX 1.
  lw_name = ls_field-value.
  IF lw_name = pw_name OR lw_name IS INITIAL.
    RETURN.
  ENDIF.

* Check new name contain no forbidden char
  lw_string = lw_name.
  TRANSLATE lw_string TO UPPER CASE.
  IF NOT lw_string CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-+.'.
    MESSAGE 'Forbidden character, operation cancelled'(e16)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  CONCATENATE pw_path pw_name INTO lw_source.
  lw_source = o_server_command->file_protect( lw_source ).
  CONCATENATE pw_path lw_name INTO lw_target.
  lw_target = o_server_command->file_protect( lw_target ).

* Confirm action on remote server
  lw_string = 'Rename # to # ?'(t05).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_source.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_target.
  PERFORM confirm_action USING lw_string 'Rename'(t30) CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Server command to rename file/folder
  CALL METHOD o_server_command->rename
    EXPORTING
      i_source = lw_source
      i_target = lw_target.

  o_server_command->commit( ).
ENDFORM.                    " RENAME_ITEM

*&---------------------------------------------------------------------*
*&      Form  SAVE_LOCAL_TO_REMOTE
*&---------------------------------------------------------------------*
*       Upload file from local pc to remote server
*----------------------------------------------------------------------*
*      -->PW_LOCAL_PATH   Path of the local file
*      -->PW_LOCAL_NAME   Name for the local file to upload
*      -->PW_REMOTE_PATH  Remote path where upload file
*      -->PW_REMOTE_NAME  Name to apply to uploaded file
*      -->PW_TRANSFERMODE Default transfer mode
*----------------------------------------------------------------------*
FORM save_local_to_remote USING pw_local_path TYPE c
                                pw_local_name TYPE c
                                pw_remote_path TYPE c
                                pw_remote_name TYPE c
                                pw_transfermode TYPE c.

  DATA : lw_localdir TYPE string,
         lw_remote_name TYPE string.
  DATA : lw_local_path(1000) TYPE c,
         lw_file(1000) TYPE c,
         ls_file TYPE string,
         lt_file LIKE TABLE OF ls_file,
         ls_file_bin(1000) TYPE x,
         lt_file_bin LIKE TABLE OF ls_file_bin,
         lw_filetype(10) TYPE c,
         lw_len TYPE i,
         lw_string TYPE string,
         lw_string2 TYPE string,
         lw_action(1) TYPE c,
         lw_filelength TYPE i.
  FIELD-SYMBOLS: <lt_file> TYPE STANDARD TABLE,
                 <ls_file> TYPE any.

* Authority check to upload files
  IF s_auth-upload NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  lw_localdir = pw_local_path.
  IF lw_localdir IS INITIAL.
    RETURN.
  ENDIF.

* add \ at end of path if necessary
  lw_local_path = lw_localdir.
  lw_len = strlen( lw_local_path ).
  lw_len = lw_len - 1.
  IF lw_local_path+lw_len(1) NE c_local_slash.
    CONCATENATE lw_localdir c_local_slash INTO lw_localdir.
  ENDIF.

* replace space by _ for server file name.
  lw_remote_name = pw_remote_name.
  TRANSLATE lw_remote_name USING ' _'.

* Define transfer mode.
  IF w_force_transfer_mode IS INITIAL.
    lw_filetype = pw_transfermode.
  ELSE.
    lw_filetype = w_force_transfer_mode.
  ENDIF.

* Use hexa table for binary transfer     @Thoul
  IF lw_filetype EQ c_bin.
    ASSIGN lt_file_bin TO <lt_file>.
  ELSE.
    ASSIGN lt_file TO <lt_file>.
  ENDIF.
  IF NOT <lt_file> IS ASSIGNED. "may not append
    RETURN.
  ENDIF.

* Save local file to local dir
  CONCATENATE lw_localdir pw_local_name INTO lw_localdir.
* check that remote file does not exist
  CONCATENATE pw_remote_path lw_remote_name INTO lw_file.
  OPEN DATASET lw_file FOR INPUT IN BINARY MODE.
* If remote file exists, overwrite confirmation
  IF sy-subrc = 0.
    CLOSE DATASET lw_file.
* Authority check to overwrite files
    IF s_auth-overwrite NE abap_true.
      MESSAGE 'Remote file already exist, cannot upload'(e17)
              TYPE c_msg_success DISPLAY LIKE c_msg_error.
      RETURN.
    ENDIF.
    lw_string = '# already exist in #. Overwrite ?'(t18).
    lw_string2 = o_server_command->file_protect( lw_localdir ).
    REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_string2.
    lw_string2 = pw_remote_path.
    lw_string2 = o_server_command->file_protect( lw_string2 ).
    REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_string2.
    lw_string2 = 'Overwrite'(t23).
* If remote file exists, upload confirmation
  ELSE.
    lw_string = 'Upload # to # ?'(t04).
    lw_string2 = o_server_command->file_protect( lw_localdir ).
    REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_string2.
    lw_string2 = pw_remote_path.
    lw_string2 = o_server_command->file_protect( lw_string2 ).
    REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_string2.
    lw_string2 = 'Upload'(t25).
  ENDIF.

* Confirm action on remote server
  PERFORM confirm_action USING lw_string lw_string2 CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Read local file
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lw_localdir
      filetype                = lw_filetype
    IMPORTING
      filelength              = lw_filelength
    CHANGING
      data_tab                = <lt_file>
    EXCEPTIONS
      file_read_error         = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      header_too_long         = 10
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc NE 0.
    MESSAGE 'Cannot read local file'(e18) TYPE c_msg_success
            DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Create remote file
  IF lw_filetype = c_bin.
* Open in binary mode
    OPEN DATASET lw_file FOR OUTPUT IN BINARY MODE.
  ELSE.
* Open in text mode
    OPEN DATASET lw_file FOR OUTPUT IN TEXT MODE ENCODING NON-UNICODE.
  ENDIF.
  IF sy-subrc <> 0.
* Error opening the file
    MESSAGE 'Cannot create remote file'(e19) TYPE c_msg_success
            DISPLAY LIKE c_msg_error.
    RETURN.
  ELSE.
*   upload file
    LOOP AT <lt_file> ASSIGNING <ls_file>.
      IF lw_filetype = c_bin.
        IF lw_filelength > 1000.
          lw_len = 1000.
        ELSE.
          lw_len = lw_filelength.
        ENDIF.
        TRANSFER <ls_file> TO lw_file LENGTH lw_len.
        lw_filelength = lw_filelength - lw_len.
      ELSE.
        TRANSFER <ls_file> TO lw_file.
      ENDIF.
    ENDLOOP.
    CLOSE DATASET lw_file.
  ENDIF.

  FREE <lt_file>.

  o_server_command->commit( ).
ENDFORM.                    " SAVE_LOCAL_TO_REMOTE

*&---------------------------------------------------------------------*
*&      Form  UNCOMPRESS_FILE
*&---------------------------------------------------------------------*
*       Uncompress some server compressed format
*    Compression format managed are : GZ, BZ2, TAR, ZIP (on AIX server)
*    TODO : add more format (z), manage Windows Server...
*----------------------------------------------------------------------*
*      -->PW_PATH  Path of the compressed file
*      -->PW_NAME  Name of the compressed file
*----------------------------------------------------------------------*
FORM uncompress_file USING pw_path TYPE c
                           pw_name TYPE c.
  DATA : lw_name TYPE string,
         lw_path TYPE string,
         lw_string TYPE string,
         lw_action(1) TYPE c.

* Authority check for uncompress files
  IF s_auth-unzip NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  CONCATENATE pw_path pw_name INTO lw_name.
  lw_name = o_server_command->file_protect( lw_name ).

* Confirm action on remote server
  lw_string = 'Uncompress # ?'(t03).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  PERFORM confirm_action USING lw_string 'Uncompress'(t31) CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

* Server command to uncompress file
  lw_name = pw_name.
  lw_path = pw_path.
  CALL METHOD o_server_command->uncompress
    EXPORTING
      i_file = lw_name "send file name unprotected
      i_path = lw_path. "send path name unprotected

  o_server_command->commit( ).
ENDFORM.                    " UNCOMPRESS_FILE

*&---------------------------------------------------------------------*
*&      Form  timestamp_convert
*&---------------------------------------------------------------------*
*       Convert unix timestamp to date/time
*----------------------------------------------------------------------*
*      -->PW_TIMESTAMP  Timestamp
*      -->PW_DATE       Date
*      -->PW_TIME       Time
*----------------------------------------------------------------------*
FORM timestamp_convert USING pw_timestamp TYPE p
                             pw_date TYPE d
                             pw_time TYPE t.
  DATA : lw_opcode TYPE x,
         lw_timestamp TYPE i,
         lw_tz TYPE systzonlo,
         lw_abapstamp TYPE char14,
         lw_abaptstamp TYPE timestamp.

* Get time zone
  IF sy-zonlo = space.
    lw_tz = sy-tzone.
    CONCATENATE 'UTC+' lw_tz INTO lw_tz.
  ELSE.
    lw_tz = sy-zonlo.
  ENDIF.

* Convert unix timestamp to abap timestamp
  lw_opcode = 3.
  lw_timestamp = pw_timestamp.
  CALL 'RstrDateConv' ID 'OPCODE'    FIELD lw_opcode
                      ID 'TIMESTAMP' FIELD lw_timestamp
                      ID 'ABAPSTAMP' FIELD lw_abapstamp.

* Convert abap timestamp to date/time fields
* According to time zone
  lw_abaptstamp = lw_abapstamp.
  CONVERT TIME STAMP lw_abaptstamp TIME ZONE lw_tz
          INTO DATE pw_date TIME pw_time.
  IF sy-subrc <> 0.
    pw_date = lw_abapstamp(8).
    pw_time = lw_abapstamp+8.
  ENDIF.
ENDFORM. " timestamp_convert

*&---------------------------------------------------------------------*
*&      Form  COPY_ITEM
*&---------------------------------------------------------------------*
*       Copy or move remote file/folder
*----------------------------------------------------------------------*
*      -->PW_NAME        File/folder to move/copy
*      -->PW_PATH_TARGET Target folder
*      -->PW_ACTION      Move : 2, copy : 1
*      -->PW_TYPE        0=file, 1=folder
*----------------------------------------------------------------------*
FORM copy_item USING pw_name TYPE c
                     pw_path_target TYPE c
                     pw_action TYPE i
                     pw_type TYPE i.
  DATA : lw_string TYPE string,
         lw_string2 TYPE string,
         lw_action(1) TYPE c,
         lw_name TYPE string,
         lw_target TYPE string,
         lw_pos TYPE i.

* Authority check for move/copy files
  IF s_auth-move_file NE abap_true AND pw_type = 0.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Authority check for move/copy folders
  IF s_auth-move_folder NE abap_true AND pw_type = 1.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  lw_name = pw_name.
  lw_name = o_server_command->file_protect( lw_name ).
  find_last_occurrence o_server_command->slash pw_name lw_pos.
  lw_pos = lw_pos + 1.
  CONCATENATE pw_path_target pw_name+lw_pos INTO lw_target.
  lw_target = o_server_command->file_protect( lw_target ).

* Confirm action on remote server
  IF pw_action = 1.
    lw_string = 'Copy # to # ?'(t01).
    lw_string2 = 'Copy'(t32).
  ELSE.
    lw_string = 'Move # to # ?'(t02).
    lw_string2 = 'Move'(t33).
  ENDIF.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_target.
  PERFORM confirm_action USING lw_string lw_string2 CHANGING lw_action.
  IF lw_action = space.
    RETURN.
  ENDIF.

  IF pw_action = 1.
* Server command to copy file/folder
    IF pw_type = 0. "file
      CALL METHOD o_server_command->copy
        EXPORTING
          i_source = lw_name
          i_target = lw_target
          i_mode   = lif_server_command=>c_copymode_file.
    ELSE. "folder
      CALL METHOD o_server_command->copy
        EXPORTING
          i_source = lw_name
          i_target = lw_target
          i_mode   = lif_server_command=>c_copymode_folder.
    ENDIF.
  ELSE.
* Server command to move file/folder
    CALL METHOD o_server_command->move
      EXPORTING
        i_source = lw_name
        i_target = lw_target.
  ENDIF.

  o_server_command->commit( ).
ENDFORM.                    " COPY_ITEM

*&---------------------------------------------------------------------*
*&      Form  INIT_ROOT_PATH
*&---------------------------------------------------------------------*
*       Get root path
*       Use this form to restrict server path acces for your users
*----------------------------------------------------------------------*
FORM init_root_path .

* Get root path from s_customize
* If not defined, take server root path
  IF s_customize-root_path IS INITIAL.
    s_customize-root_path = o_server_command->slash.
  ENDIF.

* Get the name of the current server
  CALL 'C_SAPGPARAM' ID 'NAME' FIELD 'rdisp/myname'
                     ID 'VALUE' FIELD w_server_name.

* Get root name from s_customize
* If not defined, take server name
  IF s_customize-root_name IS INITIAL.
    s_customize-root_name = w_server_name.
  ENDIF.

* Get root path length for further usage
  s_customize-root_path_len = strlen( s_customize-root_path ).
ENDFORM.                    " INIT_ROOT_PATH

*&---------------------------------------------------------------------*
*&      Form  create_shortcut
*&---------------------------------------------------------------------*
*       Create a server shortcut usable by any user
*----------------------------------------------------------------------*
*      -->PW_PATH    Path of the shortcut to create
*----------------------------------------------------------------------*
FORM create_shortcut USING pw_path TYPE c.

  DATA : ls_user_dir TYPE user_dir,
         ls_field TYPE sval,
         lt_fields LIKE TABLE OF ls_field,
         lw_dirname TYPE user_dir-dirname,
         lw_rc(1) TYPE c.

* Authority check for shortcut creation
  IF s_auth-create_shortcut NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Ask name and path
* Define Path field, a field with min length 75 and minuscule management
  ls_field-tabname = 'ADRP'.
  ls_field-fieldname = 'NAME_TEXT'.
  ls_field-fieldtext = 'Path'(h22).                       "#EC TEXT_DUP
  ls_field-field_obl = abap_true.
  ls_field-value = pw_path.
* Define Description field
  APPEND ls_field TO lt_fields.
  ls_field-tabname = 'DD03T'.
  ls_field-fieldname = 'DDTEXT'.
  ls_field-fieldtext = 'Description'(h34).
  APPEND ls_field TO lt_fields.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title = 'Enter name and server path'(t15)
    IMPORTING
      returncode  = lw_rc
    TABLES
      fields      = lt_fields
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc <> 0 OR lw_rc NE space.
    RETURN.
  ENDIF.

  READ TABLE lt_fields INTO ls_field INDEX 1.
  ls_user_dir-dirname = ls_field-value.
  IF ls_user_dir-dirname IS INITIAL.
    RETURN.
  ENDIF.

  READ TABLE lt_fields INTO ls_field INDEX 2.
  ls_user_dir-aliass = ls_field-value.
  IF ls_user_dir-aliass IS INITIAL.
    RETURN.
  ENDIF.

* Define the shortcut for all instances
  ls_user_dir-svrname = c_server_all.

* Check if shortcut already exist
  SELECT SINGLE dirname INTO lw_dirname
         FROM user_dir
         WHERE dirname = ls_user_dir-dirname.
  IF sy-subrc = 0.
    MESSAGE 'This shortcut already exists'(e22)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Add the new shortcut
  INSERT user_dir FROM ls_user_dir.
  COMMIT WORK AND WAIT.

* Refresh shortcut list
  PERFORM get_shortcuts.

  MESSAGE 'Shortcut created'(t16) TYPE c_msg_success.
ENDFORM.                    "create_shortcut

*&---------------------------------------------------------------------*
*&      Form  DELETE_SHORTCUT
*&---------------------------------------------------------------------*
*       Display a popup to ask server shortcut for deletion
*----------------------------------------------------------------------*
FORM delete_shortcut.
  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
         ls_fieldcat LIKE LINE OF lt_fieldcat,
         lw_exit(1) TYPE c,
         lw_action(1) TYPE c,
         lw_string TYPE string,
         lw_string2 TYPE string,
         lw_count TYPE i.


* Authority check to calculate folder size
  IF s_auth-delete_shortcut NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  IF t_shortcuts IS INITIAL.
    MESSAGE 'There is no shortcut to delete'(e25)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

* Build popup fieldcat
  ls_fieldcat-fieldname = 'SELKZ'.
  ls_fieldcat-checkbox = abap_true.
  ls_fieldcat-reptext_ddic = 'Selection'(h35).
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-fix_column = abap_true.
  ls_fieldcat-outputlen = 3.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ALIASS'.
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = 30.
  ls_fieldcat-reptext_ddic = 'Name'(h36).
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DIRNAME'.
  ls_fieldcat-datatype = 'CHAR'.
  ls_fieldcat-outputlen = 75.
  ls_fieldcat-reptext_ddic = 'Path'(h37).
  APPEND ls_fieldcat TO lt_fieldcat.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title               = 'Choose shortcuts to delete'(t20)
      i_selection           = abap_true
      i_allow_no_selection  = space
      i_zebra               = abap_true
      i_screen_start_column = 10
      i_screen_start_line   = 1
      i_screen_end_column   = 120
      i_screen_end_line     = 20
      i_checkbox_fieldname  = 'SELKZ'
      i_tabname             = 'T_SHORTCUTS'
      it_fieldcat           = lt_fieldcat
*     IT_EXCLUDING          =
    IMPORTING      "es_selfield           = ls_exit
      e_exit                = lw_exit
    TABLES
      t_outtab              = t_shortcuts
    EXCEPTIONS
      OTHERS                = 4.
  IF sy-subrc NE 0 OR lw_exit NE space.
    MESSAGE 'Action cancelled'(e12) TYPE c_msg_success
          DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  CLEAR lw_count.
  LOOP AT t_shortcuts INTO s_shortcut WHERE selkz = abap_true.
* Confirm deletion one by one
    lw_string = 'Delete shortcut # for path # ?'(t21).
    lw_string2 = s_shortcut-aliass.
    lw_string2 = o_server_command->file_protect( lw_string2 ).
    REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string
                             WITH lw_string2.
    lw_string2 = s_shortcut-dirname.
    lw_string2 = o_server_command->file_protect( lw_string2 ).
    REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string
                             WITH lw_string2.
    PERFORM confirm_action USING lw_string 'Delete'(t26) CHANGING lw_action.
    IF lw_action = space.
      CONTINUE.
    ENDIF.

* If deletion confirmed, delete from database
    DELETE FROM user_dir WHERE dirname = s_shortcut-dirname.
    lw_count = lw_count + 1.
  ENDLOOP.

* If no shortcut was validated, exit process
  IF lw_count = 0.
    RETURN.
  ENDIF.

* Update database
  COMMIT WORK AND WAIT.

* Display how many shortcut was deleted
  lw_string = lw_count.
  CONCATENATE lw_string 'shortcuts deleted'(t34)
              INTO lw_string SEPARATED BY space.
  MESSAGE lw_string TYPE c_msg_success.

* Refresh shortcut list
  PERFORM get_shortcuts.
ENDFORM.                    " DELETE_SHORTCUT

*&---------------------------------------------------------------------*
*&      Form  GET_SHORTCUTS
*&---------------------------------------------------------------------*
*       Get server shortcuts from database
*       Fill the table t_shortcuts
*----------------------------------------------------------------------*
FORM get_shortcuts.
  DATA lw_len TYPE i.

* Get shortcuts
  SELECT dirname aliass FROM user_dir
    INTO TABLE t_shortcuts
    WHERE svrname = w_server_name.

  SELECT dirname aliass FROM user_dir
    APPENDING TABLE t_shortcuts
    WHERE svrname = c_server_all.

* Limit shortcuts to server path access restriction
  LOOP AT t_shortcuts INTO s_shortcut.
    lw_len = strlen( s_shortcut-dirname ).
    IF s_customize-root_path_len GT 1
    AND ( lw_len LT s_customize-root_path_len
    OR s_shortcut-dirname(s_customize-root_path_len)
       NE s_customize-root_path ).
      DELETE t_shortcuts.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_SHORTCUTS

*&---------------------------------------------------------------------*
*&      Form  CHMOD
*&---------------------------------------------------------------------*
*       Display/change CHMOD of the file/folder (regarding to auth)
*----------------------------------------------------------------------*
*      -->PW_PATH  Path of the file/folder to CHMOD
*      -->PW_NAME  File/folder to CHMOD
*      -->PW_MODE  Current CHMOD value
*      -->PW_OWNER Owner of the file/folder
*----------------------------------------------------------------------*
FORM chmod USING pw_path LIKE s_detail2-path
                 pw_name LIKE s_detail2-name
                 pw_mode LIKE s_detail2-mode
                 pw_owner LIKE s_detail2-owner.
  DATA : lt_ptab TYPE wdy_wb_property_tab,
         ls_ptab TYPE wdy_wb_property,
         lw_string TYPE string,
         lw_name TYPE string,
         lw_params TYPE string,
         lw_action(1) TYPE c,
         lw_offset TYPE i,
         lw_value TYPE i.

* Set CHMOD & owner to display
  w_chmod_to_set = pw_mode.
  w_owner_to_set = pw_owner.

* Display it
  CALL SCREEN 200 STARTING AT 40 10
                  ENDING AT 70 21.

  IF w_okcode NE 'OK' OR s_auth-chmod NE abap_true.
    RETURN.
  ENDIF.

* Change server value
  lt_ptab = o_pbox_chmod->get_properties( ).
  w_chmod_to_set = '000'.
  LOOP AT lt_ptab INTO ls_ptab.

    CASE ls_ptab-category.
      WHEN 'OWNER'.
        lw_offset = 0.
      WHEN 'GROUP'.
        lw_offset = 1.
      WHEN 'OTHER'.
        lw_offset = 2.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    CASE ls_ptab-name.
      WHEN 'READ'.
        lw_value = 4.
      WHEN 'WRITE'.
        lw_value = 2.
      WHEN 'EXE'.
        lw_value = 1.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
    IF ls_ptab-value NE space.
      w_chmod_to_set+lw_offset(1) = w_chmod_to_set+lw_offset(1)
                                    + lw_value.
    ENDIF.
  ENDLOOP.
* If no change, leave process
  IF w_chmod_to_set = pw_mode.
    RETURN.
  ENDIF.

  CONCATENATE pw_path pw_name INTO lw_name.
  lw_name = o_server_command->file_protect( lw_name ).

* Change detected, confirm action on remote server
  lw_string = 'Change CHMOD for file # from # to # ?'(t17).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH pw_mode.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string
          WITH w_chmod_to_set.
  PERFORM confirm_action USING lw_string 'Change'(t35)
          CHANGING lw_action.
  IF lw_action = space.
    CLEAR w_chmod_to_set.
    RETURN.
  ENDIF.

  lw_params = w_chmod_to_set.

* Server command to CHMOD file/folder
  CALL METHOD o_server_command->change_attrib
    EXPORTING
      i_params = lw_params
      i_file   = lw_name.

  o_server_command->commit( ).
ENDFORM.                    " CHMOD

*&---------------------------------------------------------------------*
*&      Form  INIT_CHMOD
*&---------------------------------------------------------------------*
*       Initialize CHMOD window - Manage change mode regarding auth
*----------------------------------------------------------------------*
FORM init_chmod .
  DATA : lt_ptab TYPE wdy_wb_property_tab,
         ls_ptab TYPE wdy_wb_property,
         lw_string TYPE string,
         lw_val TYPE i,
         lw_pos TYPE i.

  DEFINE add_chmod_param. "name[SEPARATOR/READ/WRITE/EXE] category[OWNER/GROUP/OTHER] label
    clear ls_ptab.
    ls_ptab-name = &1.
* Title line
    if &1 = 'SEPARATOR'.                                   "#EC BOOL_OK
      ls_ptab-type = cl_wdy_wb_property_box=>separator.
      ls_ptab-enabled = abap_true.
* Flag line
    else.
      ls_ptab-type = cl_wdy_wb_property_box=>property_type_boolean.
      ls_ptab-enabled = s_auth-chmod.
      case &1.
        when 'READ'.
          lw_val = 4.
        when 'WRITE'.
          lw_val = 2.
        when 'EXE'.
          lw_val = 1.
      endcase.
      case &2.
        when 'OWNER'.
          lw_pos = 0.
        when 'GROUP'.
          lw_pos = 1.
        when 'OTHER'.
          lw_pos = 2.
      endcase.
      if w_chmod_to_set+lw_pos(1) ge lw_val.
        ls_ptab-value = abap_true.
        w_chmod_to_set+lw_pos(1) = w_chmod_to_set+lw_pos(1) - lw_val.
      else.
        ls_ptab-value = space.
      endif.
    endif.
    ls_ptab-category = &2.
    ls_ptab-display_name = &3.
    ls_ptab-value_style = cl_wdy_wb_property_box=>style_enabled.
    append ls_ptab to lt_ptab.
  END-OF-DEFINITION.

* Create a "group" for Owner auth
  CONCATENATE 'Owner'(h18) ' (' w_owner_to_set ')' INTO lw_string.
  add_chmod_param 'SEPARATOR' 'OWNER' lw_string.
  add_chmod_param 'READ' 'OWNER' 'Read'(h13).
  add_chmod_param 'WRITE' 'OWNER' 'Write'(h14).
  add_chmod_param 'EXE' 'OWNER' 'Execute'(h15).

* Create a "group" for file group auth
  add_chmod_param 'SEPARATOR' 'GROUP' 'File group'(h19).
  add_chmod_param 'READ' 'GROUP' 'Read'(h13).
  add_chmod_param 'WRITE' 'GROUP' 'Write'(h14).
  add_chmod_param 'EXE' 'GROUP' 'Execute'(h15).

* Create a "group" for Others auth
  add_chmod_param 'SEPARATOR' 'OTHER' 'Others'(h20).
  add_chmod_param 'READ' 'OTHER' 'Read'(h13).
  add_chmod_param 'WRITE' 'OTHER' 'Write'(h14).
  add_chmod_param 'EXE' 'OTHER' 'Execute'(h15).

  CLEAR : w_chmod_to_set,
          w_owner_to_set.

* Create a custom container linked to the custom controm on screen 200
  CREATE OBJECT o_container_chmod
    EXPORTING
      container_name              = 'CUSTCONT2'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Create the property object and link it to the custom controm
  CREATE OBJECT o_pbox_chmod
    EXPORTING
      parent                    = o_container_chmod
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Define Column title of the property object
  CALL METHOD o_pbox_chmod->initialize
    EXPORTING
      property_column_title = 'Property'(h16)
      value_column_title    = 'Value'(h17).

* Set change mode according to authorization
  o_pbox_chmod->set_enabled( s_auth-chmod ).

* Fill properties/values
  CALL METHOD o_pbox_chmod->set_properties
    EXPORTING
      properties = lt_ptab
      refresh    = abap_true.

ENDFORM.                    " INIT_CHMOD

*&---------------------------------------------------------------------*
*&      Form  UPDATE_CHMOD
*&---------------------------------------------------------------------*
*       Update the CHMOD value from w_chmod_to_set to the screen 200
*----------------------------------------------------------------------*
FORM update_chmod .
  DATA : ls_ptab TYPE wdy_wb_property,
         lw_string TYPE string,
         lw_val TYPE i,
         lw_pos TYPE i.

  DEFINE update_chmod_param. "name[SEPARATOR/READ/WRITE/EXE] category[OWNER/GROUP/OTHER] label
    clear ls_ptab.
    ls_ptab-name = &1.
* Title line
    if &1 = 'SEPARATOR'.                                   "#EC BOOL_OK
      ls_ptab-type = cl_wdy_wb_property_box=>separator.
      ls_ptab-enabled = abap_true.
* Flag line
    else.
      ls_ptab-type = cl_wdy_wb_property_box=>property_type_boolean.
      ls_ptab-enabled = s_auth-chmod.
      case &1.
        when 'READ'.
          lw_val = 4.
        when 'WRITE'.
          lw_val = 2.
        when 'EXE'.
          lw_val = 1.
      endcase.
      case &2.
        when 'OWNER'.
          lw_pos = 0.
        when 'GROUP'.
          lw_pos = 1.
        when 'OTHER'.
          lw_pos = 2.
      endcase.
      if w_chmod_to_set+lw_pos(1) ge lw_val.
        ls_ptab-value = abap_true.
        w_chmod_to_set+lw_pos(1) = w_chmod_to_set+lw_pos(1) - lw_val.
      else.
        ls_ptab-value = space.
      endif.
    endif.
    ls_ptab-category = &2.
    ls_ptab-display_name = &3.
    ls_ptab-value_style = cl_wdy_wb_property_box=>style_enabled.

    call method o_pbox_chmod->update_property
      exporting
        property = ls_ptab.
  END-OF-DEFINITION.

* Update Owner name
  CONCATENATE 'Owner'(h18) ' (' w_owner_to_set ')' INTO lw_string.
  update_chmod_param 'SEPARATOR' 'OWNER' lw_string.

* Update Owner section
  update_chmod_param 'READ' 'OWNER' 'Read'(h13).
  update_chmod_param 'WRITE' 'OWNER' 'Write'(h14).
  update_chmod_param 'EXE' 'OWNER' 'Execute'(h15).

* Update File group section
  update_chmod_param 'READ' 'GROUP' 'Read'(h13).
  update_chmod_param 'WRITE' 'GROUP' 'Write'(h14).
  update_chmod_param 'EXE' 'GROUP' 'Execute'(h15).

* Update Other section
  update_chmod_param 'READ' 'OTHER' 'Read'(h13).
  update_chmod_param 'WRITE' 'OTHER' 'Write'(h14).
  update_chmod_param 'EXE' 'OTHER' 'Execute'(h15).

  CLEAR : w_chmod_to_set,
          w_owner_to_set.

ENDFORM.                    " UPDATE_CHMOD

*&---------------------------------------------------------------------*
*&      Form  attrib
*&---------------------------------------------------------------------*
*       Display/change Attributes of the file/folder (regarding to auth)
*----------------------------------------------------------------------*
*      -->PW_PATH  Path of the file/folder to CHMOD
*      -->PW_NAME  File/folder to CHMOD
*      -->PW_ATTRIB Current Attributes values
*----------------------------------------------------------------------*
FORM attrib USING pw_path LIKE s_detail2-path
                  pw_name LIKE s_detail2-name
                  pw_attrib LIKE s_detail2-attrs.

  DATA : lt_ptab TYPE wdy_wb_property_tab,
         ls_ptab TYPE wdy_wb_property,
         lw_string TYPE string,
         lw_name TYPE string,
         lw_params TYPE string,
         lw_attrs_check LIKE w_attrib_to_set,
         lw_att(2) TYPE c,
         lw_action(1) TYPE c.

* Set attribs to display
  w_attrib_to_set = pw_attrib.
  w_owner_to_set = abap_true. "used to force attrib update in case of empty attrib

* Display it
  CALL SCREEN 200 STARTING AT 40 10
                  ENDING AT 70 21.

  IF w_okcode NE 'OK' OR s_auth-chmod NE abap_true.
    RETURN.
  ENDIF.

* Change server value
  lt_ptab = o_pbox_chmod->get_properties( ).

  CLEAR w_attrib_to_set.
  LOOP AT lt_ptab INTO ls_ptab
    WHERE type = 'FLAG'
      AND value = abap_true.
    CONCATENATE w_attrib_to_set ls_ptab-name(1) INTO w_attrib_to_set.
  ENDLOOP.

* If no change, leave process
  IF w_attrib_to_set = pw_attrib.
    RETURN.
  ENDIF.

  CLEAR lw_params.
* Check attributes added
  lw_attrs_check = w_attrib_to_set.
  DO.
    lw_att = lw_attrs_check(1).
    IF NOT pw_attrib CS lw_att.
      CONCATENATE '+' lw_att INTO lw_att.
      CONCATENATE lw_params lw_att INTO lw_params SEPARATED BY space.
    ENDIF.
    SHIFT lw_attrs_check LEFT.
    IF sy-subrc <> 0 OR lw_att IS INITIAL.
      EXIT.
    ENDIF.
  ENDDO.

* Check attributes removed
  lw_attrs_check = pw_attrib.
  DO.
    lw_att = lw_attrs_check(1).
    IF NOT w_attrib_to_set CS lw_att.
      CONCATENATE '-' lw_att INTO lw_att.
      CONCATENATE lw_params lw_att INTO lw_params SEPARATED BY space.
    ENDIF.
    SHIFT lw_attrs_check LEFT.
    IF sy-subrc <> 0 OR lw_att IS INITIAL.
      EXIT. "exit do
    ENDIF.
  ENDDO.

* If no change, leave process
* Can occurs if same param in different order
  IF lw_params IS INITIAL.
    RETURN.
  ENDIF.

  CONCATENATE pw_path pw_name INTO lw_name.
  lw_name = o_server_command->file_protect( lw_name ).

* Change detected, confirm action on remote server
  lw_string = 'Change CHMOD for file # from # to # ?'(t17).
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH lw_name.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string WITH pw_attrib.
  REPLACE FIRST OCCURRENCE OF c_wildcard IN lw_string
          WITH w_attrib_to_set.
  PERFORM confirm_action USING lw_string 'Change'(t35) CHANGING lw_action.
  IF lw_action = space.
    CLEAR w_attrib_to_set.
    RETURN.
  ENDIF.

* Server command to CHMOD file/folder
  CALL METHOD o_server_command->change_attrib
    EXPORTING
      i_params = lw_params
      i_file   = lw_name.

  o_server_command->commit( ).
ENDFORM.                    "attrib

*&---------------------------------------------------------------------*
*&      Form  init_attrib
*&---------------------------------------------------------------------*
*       Initialize Attributes window - Manage change mode regarding auth
*----------------------------------------------------------------------*
FORM init_attrib.
  DATA : lt_ptab TYPE wdy_wb_property_tab,
         ls_ptab TYPE wdy_wb_property.

  DEFINE add_attr_param. "name[SEPARATOR/...] label
    clear ls_ptab.
    ls_ptab-name = &1.
    ls_ptab-display_name = &2.
    ls_ptab-enabled = abap_true.
* Title line
    if &1 = 'SEPARATOR'.                                   "#EC BOOL_OK
      ls_ptab-type = cl_wdy_wb_property_box=>separator.
* Flag line
    else.
      ls_ptab-type = cl_wdy_wb_property_box=>property_type_boolean.
      if w_attrib_to_set cs ls_ptab-name(1).
        ls_ptab-value = abap_true.
      endif.
    endif.
    ls_ptab-value_style = cl_wdy_wb_property_box=>style_enabled.
    append ls_ptab to lt_ptab.
  END-OF-DEFINITION.

  add_attr_param 'SEPARATOR' 'File Attributes'(h23).
  add_attr_param 'READ' 'Read-Only'(h24).
  add_attr_param 'ARCHIVE' 'Archive'(h25).
  add_attr_param 'SYSTEM' 'System File'(h26).
  add_attr_param 'HIDDEN' 'Hidden File'(h27).
  add_attr_param 'INDEXED' 'Not Content Indexed'(h28).
  add_attr_param 'COMPRESSED' 'Compressed'(h29).
  add_attr_param 'OFFLINE' 'Offline'(h30).
*  add_attr_param 'V' 'Integrity (Win8 ReFS only)'.
*  add_attr_param 'X' 'No Scrub Data (Win8 ReFS only)'.

* Create a custom container linked to the custom controm on screen 200
  CREATE OBJECT o_container_chmod
    EXPORTING
      container_name              = 'CUSTCONT2'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Create the property object and link it to the custom controm
  CREATE OBJECT o_pbox_chmod
    EXPORTING
      parent                    = o_container_chmod
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Define Column title of the property object
  CALL METHOD o_pbox_chmod->initialize
    EXPORTING
      property_column_title = 'Property'(h16)
      value_column_title    = 'Value'(h17).

* Set change mode according to authorization
  o_pbox_chmod->set_enabled( s_auth-chmod ).

* Fill properties/values
  CALL METHOD o_pbox_chmod->set_properties
    EXPORTING
      properties = lt_ptab
      refresh    = abap_true.

  CLEAR w_attrib_to_set.
  CLEAR w_owner_to_set.
ENDFORM.                    "init_attrib

*&---------------------------------------------------------------------*
*&      Form  update_attrib
*&---------------------------------------------------------------------*
*  Update the Attributes value from w_chmod_to_set to the screen 200
*----------------------------------------------------------------------*
FORM update_attrib.
  DATA ls_ptab TYPE wdy_wb_property.

  DEFINE update_attr_param. "name label
    clear ls_ptab.
    ls_ptab-name = &1.
    ls_ptab-display_name = &2.
    ls_ptab-type = cl_wdy_wb_property_box=>property_type_boolean.
    if w_attrib_to_set cs ls_ptab-name(1).
      ls_ptab-value = abap_true.
    else.
      ls_ptab-value = space.
    endif.
    ls_ptab-enabled = abap_true.
    ls_ptab-value_style = cl_wdy_wb_property_box=>style_enabled.
    call method o_pbox_chmod->update_property
      exporting
        property = ls_ptab.
  END-OF-DEFINITION.

  update_attr_param 'READ' 'Read-Only'(h24).
  update_attr_param 'ARCHIVE' 'Archive'(h25).
  update_attr_param 'SYSTEM' 'System File'(h26).
  update_attr_param 'HIDDEN' 'Hidden File'(h27).
  update_attr_param 'INDEXED' 'Not Content Indexed'(h28).
  update_attr_param 'COMPRESSED' 'Compressed'(h29).
  update_attr_param 'OFFLINE' 'Offline'(h30).

  CLEAR w_attrib_to_set.
  CLEAR w_owner_to_set.
ENDFORM.                    "update_attrib

*&---------------------------------------------------------------------*
*&      Form  init_auth
*&---------------------------------------------------------------------*
*       Define allowed actions
*       Use this form to restrict actions for your users
*       with an auth object for example
*
*       Download authorization is required to open remote files !
*----------------------------------------------------------------------*
FORM init_auth.

* Check User can execute C function
  AUTHORITY-CHECK OBJECT 'S_C_FUNCT'
                  ID 'ACTVT' FIELD '16'
                  ID 'CFUNCNAME' FIELD ' '
                  ID 'PROGRAM' FIELD 'ZAL11'.
  IF sy-subrc NE 0.
* If not allowed, it is not possible to :
* - Compress/uncompress
* - Create folder
* - Move file/folder
* - Duplicate file/folder
* - Rename file/folder
* - Delete file/folder
* - CHMOD
    CLEAR : s_auth-zip,
            s_auth-unzip,
            s_auth-create_folder,
            s_auth-move_file,
            s_auth-move_folder,
            s_auth-duplicate_file,
            s_auth-duplicate_folder,
            s_auth-rename_file,
            s_auth-rename_folder,
            s_auth-delete_file,
            s_auth-delete_folder,
            s_auth-chmod.
  ENDIF.

* Individual checks : done only if auth object defined
  IF s_customize-auth_object IS INITIAL
  OR s_customize-auth_id IS INITIAL.
    RETURN.
  ENDIF.

* Check if user is allowed to download / open remote file
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'DL'.
  IF sy-subrc NE 0.
    CLEAR s_auth-download.
  ENDIF.

* Check if user is allowed to upload
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'UL'.
  IF sy-subrc NE 0.
    CLEAR s_auth-upload.
  ENDIF.

* Check if user is allowed to overwrite (on upload)
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'ULOVER'.
  IF sy-subrc NE 0.
    CLEAR s_auth-upload.
  ENDIF.

* Check if user is allowed to zip
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'ZIP'.
  IF sy-subrc NE 0.
    CLEAR s_auth-zip.
  ENDIF.

* Check if user is allowed to unzip
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'UNZIP'.
  IF sy-subrc NE 0.
    CLEAR s_auth-unzip.
  ENDIF.

* Check if user is allowed to rename files
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FILEREN'.
  IF sy-subrc NE 0.
    CLEAR s_auth-rename_file.
  ENDIF.

* Check if user is allowed to rename folders
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FOLDREN'.
  IF sy-subrc NE 0.
    CLEAR s_auth-rename_folder.
  ENDIF.

* Check if user is allowed to duplicate files
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FILEDUP'.
  IF sy-subrc NE 0.
    CLEAR s_auth-duplicate_file.
  ENDIF.

* Check if user is allowed to duplicate folders
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FOLDDUP'.
  IF sy-subrc NE 0.
    CLEAR s_auth-duplicate_folder.
  ENDIF.

* Check if user is allowed to move/copy files
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FILEMOV'.
  IF sy-subrc NE 0.
    CLEAR s_auth-move_file.
  ENDIF.

* Check if user is allowed to move/copy folders
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FOLDMOV'.
  IF sy-subrc NE 0.
    CLEAR s_auth-move_folder.
  ENDIF.

* Check if user is allowed to delete files
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FILEDEL'.
  IF sy-subrc NE 0.
    CLEAR s_auth-delete_file.
  ENDIF.

* Check if user is allowed to delete folders
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FOLDDEL'.
  IF sy-subrc NE 0.
    CLEAR s_auth-delete_folder.
  ENDIF.

* Check if user is allowed to create folders
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'FOLDCRE'.
  IF sy-subrc NE 0.
    CLEAR s_auth-create_folder.
  ENDIF.

* Check if user is allowed to use server shortcuts
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'SHORTCUT'.
  IF sy-subrc NE 0.
    CLEAR s_auth-shortcut.
  ENDIF.

* Check if user is allowed to create server shortcuts
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'SHORTCRE'.
  IF sy-subrc NE 0.
    CLEAR s_auth-create_shortcut.
  ENDIF.

* Check if user is allowed to create server shortcuts
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'SHORTDEL'.
  IF sy-subrc NE 0.
    CLEAR s_auth-delete_shortcut.
  ENDIF.

* Check if user is allowed to copy server path
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'COPYPATH'.
  IF sy-subrc NE 0.
    CLEAR s_auth-copy_path.
  ENDIF.

* Check if user is allowed to paste server path
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'PASTPATH'.
  IF sy-subrc NE 0.
    CLEAR s_auth-paste_path.
  ENDIF.

* Check if user is allowed to CHMOD remote file/folder
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'CHMOD'.
  IF sy-subrc NE 0.
    CLEAR s_auth-chmod.
  ENDIF.

* Check if user is allowed to calculate folder size
  AUTHORITY-CHECK OBJECT s_customize-auth_object
           ID s_customize-auth_id FIELD 'DIRSIZE'.
  IF sy-subrc NE 0.
    CLEAR s_auth-dirsize.
  ENDIF.

ENDFORM.                    "init_auth

*&---------------------------------------------------------------------*
*&      Form  get_windows_special_folders
*&---------------------------------------------------------------------*
*       Search path of special windows folder in registry
*----------------------------------------------------------------------*
*      -->FP_FOLDER  Folder to find in windows registry
*      -->FP_PATH    Path of the folder
*----------------------------------------------------------------------*
FORM get_windows_special_folders  USING fp_folder TYPE string
                                  CHANGING fp_path TYPE string.

  CLEAR fp_path.

  CALL METHOD cl_gui_frontend_services=>registry_get_value
    EXPORTING
      root                 = cl_gui_frontend_services=>hkey_current_user
      key                  = 'Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' "#EC NOTEXT
      value                = fp_folder
    IMPORTING
      reg_value            = fp_path
    EXCEPTIONS
      get_regvalue_failed  = 1
      cntl_error           = 2
      error_no_gui         = 3
      not_supported_by_gui = 4
      OTHERS               = 5.
  IF sy-subrc NE 0 OR fp_path IS INITIAL.
    CALL METHOD cl_gui_frontend_services=>registry_get_value
      EXPORTING
        root                 = cl_gui_frontend_services=>hkey_current_user
        key                  = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' "#EC NOTEXT
        value                = fp_folder
      IMPORTING
        reg_value            = fp_path
      EXCEPTIONS
        get_regvalue_failed  = 1
        cntl_error           = 2
        error_no_gui         = 3
        not_supported_by_gui = 4
        OTHERS               = 5.
  ENDIF.

ENDFORM.                    " get_windows_special_folders

*&---------------------------------------------------------------------*
*&      Form  GET_REMOTE_FOLDER_SIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_remote_folder_size .
  DATA lw_name TYPE string.

* Authority check to calculate folder size
  IF s_auth-dirsize NE abap_true.
    MESSAGE 'You are not allowed to perform this action'(e21)
            TYPE c_msg_success DISPLAY LIKE c_msg_error.
    RETURN.
  ENDIF.

  LOOP AT t_details2 INTO s_detail2 WHERE dir = 1.
    CHECK s_detail2-name NE '..'.

    CONCATENATE s_detail2-path s_detail2-name INTO lw_name.
    lw_name = o_server_command->file_protect( lw_name ).
    s_detail2-len = o_server_command->get_folder_size( lw_name ).
    MODIFY t_details2 FROM s_detail2 TRANSPORTING len.
  ENDLOOP.

ENDFORM.                    " GET_REMOTE_FOLDER_SIZE

*&---------------------------------------------------------------------*
*&      Form  ADD_NEW_SERVER_REMOTE
*&---------------------------------------------------------------------*
*       Add a distant server in the server tree
*----------------------------------------------------------------------*
*      -->PW_PATH Path of the server to add
*----------------------------------------------------------------------*
FORM add_new_server_remote USING pw_path TYPE c
                                 pw_parent LIKE s_node.
  DATA : lt_nodes_new LIKE t_nodes2,
         lw_key(4) TYPE n.

  CLEAR s_node.

* Search available nodekey
  IF pw_parent IS INITIAL.
    lw_key = 1.
    DO.
      CONCATENATE 'ROOT' lw_key INTO s_node-node_key.
      READ TABLE t_nodes2 WITH KEY node_key = s_node-node_key
                 TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        EXIT. "exit do
      ENDIF.
      lw_key = lw_key + 1.
    ENDDO.
    s_node-n_image = s_node-exp_image = '@6L@'.
  ELSE.

    w_node2_count = w_node2_count + 1.
    s_node-node_key = w_node2_count.
    s_node-relatkey = pw_parent-node_key.
  ENDIF.
  s_node-relatship = cl_gui_simple_tree=>relat_last_child.
  s_node-isfolder = abap_true.
  s_node-text = pw_path.
  CONCATENATE pw_parent-path pw_path o_server_command->slash
              INTO s_node-path.
  s_node-texttosort = s_node-text.
  TRANSLATE s_node-texttosort TO LOWER CASE.
  s_node-dragdropid = w_handle_tree2.
  APPEND s_node TO t_nodes2.
  APPEND s_node TO lt_nodes_new.

  CALL METHOD o_tree2->add_nodes
    EXPORTING
      table_structure_name = 'MTREESNODE'
      node_table           = lt_nodes_new
    EXCEPTIONS
      OTHERS               = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " ADD_NEW_SERVER_REMOTE

*&---------------------------------------------------------------------*
*&      Form  ADD_REMOTE_LOGICAL_FOLDERS
*&---------------------------------------------------------------------*
*       Get all logical folders - like AL11
*       Add them in t_nodes2
*       Got from standard RSWATCH0 - form main
*----------------------------------------------------------------------*
FORM add_remote_logical_folders.
  DATA lw_dirname TYPE dirname_al11.

  DEFINE add_folder.
    call 'C_SAPGPARAM' id 'NAME'  field &1
                       id 'VALUE' field lw_dirname.
    if sy-subrc = 0 and not lw_dirname is initial.
      add_folder_node &2 lw_dirname.
    endif.
  END-OF-DEFINITION.

  DEFINE add_folder_node.
    clear s_node.
    w_node2_count = w_node2_count + 1.
    s_node-node_key = w_node2_count.
    s_node-relatkey = 'SHORTCUT'.
*    s_node-isfolder = abap_true.
    s_node-text = &1.
    concatenate '#' &2 o_server_command->slash into s_node-path.
    s_node-n_image = s_node-exp_image = '@1F@'.
    append s_node to t_nodes2.
  END-OF-DEFINITION.

* Add new root for shortcuts
  CLEAR s_node.
  s_node-node_key = 'SHORTCUT'.
  s_node-isfolder = abap_true.
  s_node-expander = abap_true.
  s_node-text = 'Directory Parameters'(c56).
  s_node-path = space.
  s_node-notreadable = abap_true.
  s_node-n_image = s_node-exp_image = '@CQ@'.
  APPEND s_node TO t_nodes2.

  IF sy-dbsys(3) = 'ADA'.
    add_folder 'DBROOT' 'DIR_ADA_DBROOT'.
  ENDIF.

  add_folder 'DIR_ATRA' 'DIR_ATRA'.
  add_folder 'DIR_BINARY' 'DIR_BINARY'.
  add_folder 'DIR_CCMS' 'DIR_CCMS'.
  add_folder 'DIR_CT_LOGGING' 'DIR_CT_LOGGING'.
  add_folder 'DIR_CT_RUN' 'DIR_CT_RUN'.
  add_folder 'DIR_DATA' 'DIR_DATA'.
  IF sy-dbsys(3) = 'DB6'.
    add_folder 'INSTHOME' 'DIR_DB2_HOME'.
  ENDIF.
  add_folder 'DIR_DBMS' 'DIR_DBMS'.
  add_folder 'DIR_EXECUTABLE' 'DIR_EXECUTABLE'.
  add_folder 'DIR_EXE_ROOT' 'DIR_EXE_ROOT'.
  add_folder 'DIR_GEN' 'DIR_GEN'.
  add_folder 'DIR_GEN_ROOT' 'DIR_GEN_ROOT'.
  add_folder 'DIR_GLOBAL' 'DIR_GLOBAL'.
  add_folder 'DIR_GRAPH_EXE' 'DIR_GRAPH_EXE'.
  add_folder 'DIR_GRAPH_LIB' 'DIR_GRAPH_LIB'.
  add_folder 'DIR_HOME' 'DIR_HOME'.
  IF sy-dbsys(3) = 'INF'.
    add_folder 'INFORMIXDIR' 'DIR_INF_INFORMIXDIR'.
  ENDIF.
  add_folder 'DIR_INSTALL' 'DIR_INSTALL'.
  add_folder 'DIR_INSTANCE' 'DIR_INSTANCE'.
  add_folder 'DIR_LIBRARY' 'DIR_LIBRARY'.
  add_folder 'DIR_LOGGING' 'DIR_LOGGING'.
  add_folder 'DIR_MEMORY_INSPECTOR' 'DIR_MEMORY_INSPECTOR'.
  IF sy-dbsys(3) = 'ORA'.
    add_folder 'DIR_ORAHOME' 'DIR_ORAHOME'.
  ENDIF.
  add_folder 'DIR_PAGING' 'DIR_PAGING'.
  add_folder 'DIR_PUT' 'DIR_PUT'.
  add_folder 'DIR_PERF' 'DIR_PERF'.
  add_folder 'DIR_PROFILE' 'DIR_PROFILE'.
  add_folder 'DIR_PROTOKOLLS' 'DIR_PROTOKOLLS'.
  add_folder 'DIR_REORG' 'DIR_REORG'.
  add_folder 'DIR_ROLL' 'DIR_ROLL'.
  add_folder 'DIR_RSYN' 'DIR_RSYN'.

* calculate directory for saphostagent (no sapparam available...)
  IF ( sy-opsys(3) = 'WIN' ) OR ( sy-opsys(3) = 'Win' ).
*   hoping that ProgramFiles is set in service user environment
    CALL 'C_GETENV' ID 'NAME'  FIELD 'ProgramFiles'
                    ID 'VALUE' FIELD lw_dirname.
    IF lw_dirname IS INITIAL.
*     %ProgramFiles% not available. guess from windir
      CALL 'C_GETENV' ID 'NAME'  FIELD 'windir'
                      ID 'VALUE' FIELD lw_dirname.
*     e.g. S:\WINDOWS ==> S:\Program Files
      lw_dirname+3 = 'Program Files'.                       "#EC NOTEXT
    ENDIF.
    CONCATENATE lw_dirname '\SAP\hostctrl' INTO lw_dirname.
  ELSE.
*   on UNIX, the path is hard coded
    lw_dirname = '/usr/sap/hostctrl'.
  ENDIF.
  add_folder_node 'DIR_SAPHOSTAGENT' lw_dirname.

*????? 'DIR_SAPUSERS' 'DIR_SAPUSERS'. "todo

  add_folder 'DIR_SETUPS' 'DIR_SETUPS'.
  add_folder 'DIR_SORTTMP' 'DIR_SORTTMP'.
  add_folder 'DIR_SOURCE' 'DIR_SOURCE'.
  add_folder 'DIR_TEMP' 'DIR_TEMP'.
  add_folder 'DIR_TRANS' 'DIR_TRANS'.
  add_folder 'DIR_TRFILES' 'DIR_TRFILES'.
  add_folder 'DIR_TRSUB' 'DIR_TRSUB'.

ENDFORM.                    " ADD_REMOTE_LOGICAL_FOLDERS

*&---------------------------------------------------------------------*
*&      Form  MANAGE_SERVER_LINK
*&---------------------------------------------------------------------*
*       Add/Remove Server link to abap variant table
*----------------------------------------------------------------------*
*      -->PW_PATH   Link to add/remove
*----------------------------------------------------------------------*
FORM manage_server_link USING pw_path TYPE c.
  DATA : lw_key TYPE indx-srtfd,
         ls_server_link LIKE LINE OF t_server_link.

  READ TABLE t_server_link TRANSPORTING NO FIELDS WITH KEY low = pw_path.
  IF sy-subrc = 0.
    DELETE t_server_link INDEX sy-tabix.
  ELSE.
    CLEAR ls_server_link.
    ls_server_link-selname = 'SERVER'.
    ls_server_link-kind = 'S'.
    ls_server_link-sign = 'I'.
    ls_server_link-option = 'EQ'.
    ls_server_link-low = pw_path.
    APPEND ls_server_link TO t_server_link.
  ENDIF.

  CONCATENATE 'ZAL11' sy-uname INTO lw_key.
  EXPORT t_server_link FROM t_server_link
         TO DATABASE indx(za) ID lw_key.

ENDFORM.                    " MANAGE_SERVER_LINK

*&---------------------------------------------------------------------*
*&      Form  GET_SERVER_LINK
*&---------------------------------------------------------------------*
*       Get list of distant server to display at start
*       Fill t_server_link
*       Add all link to remote tree
*----------------------------------------------------------------------*
FORM get_server_link .
  DATA : lw_key TYPE indx-srtfd,
         ls_server_link LIKE LINE OF t_server_link.

  CONCATENATE 'ZAL11' sy-uname INTO lw_key.
  IMPORT t_server_link TO t_server_link
         FROM DATABASE indx(za) ID lw_key.

  LOOP AT t_server_link INTO ls_server_link.
    PERFORM goto_shortcut USING ls_server_link-low 2 abap_true.
  ENDLOOP.
ENDFORM.                    " GET_SERVER_LINK
