unit genfsbase;

interface

{$MODE OBJFPC}

uses Classes,SysUtils,fsbase;

const genfs_var_byte=0;
      genfs_var_word=1;
      genfs_var_dword=2;
      genfs_var_qword=3;
      genfs_var_smallint=4;
      genfs_var_shortint=5;
      genfs_var_integer=6;
      genfs_var_int64=7;

type Integer=-$7FFFFFFF..$7FFFFFFF;
     genfs_variant=packed record
                   vartype:byte;
                   case Byte of
                   0:(genfs_byte:byte;);
                   1:(genfs_word:word;);
                   2:(genfs_dword:dword;);
                   3:(genfs_qword:qword;);
                   4:(genfs_smallint:smallint;);
                   5:(genfs_shortint:shortint;);
                   6:(genfs_integer:integer;);
                   7:(genfs_int64:int64;);
                   end;
     genfs_fat=packed record
               header:fat_header;
               fatbit:byte;
               entrypair:^fat_entry_pair;
               entrycount:SizeUint;
               datastart:SizeUint;
               end;
     genfs_fat32=packed record
                 header:fat32_header;
                 fsinfo:fat_fsinfo_structure;
                 entrypair:^fat_entry_pair;
                 entrycount:SizeUint;
                 datastart:SizeUint;
                 end;
     genfs_exfat=packed record

                 end;
     genfs_ntfs=packed record

                end;
     genfs_ext2=packed record

                end;
     genfs_ext3=packed record

                end;
     genfs_ext4=packed record

                end;
     genfs_btrfs=packed record

                 end;
     genfs_file=packed record
                filename:string;
                Position:SizeUint;
                Size:SizeUint;
                end;
     genfs_filesystem=packed record
                      linkfilename:Unicodestring;
                      fsname:byte;
                      case Byte of
                      0:(fat12:genfs_fat;);
                      1:(fat16:genfs_fat;);
                      2:(fat32:genfs_fat32;);
                      3:(exfat:genfs_exfat;);
                      4:(ntfs:genfs_ntfs;);
                      5:(ext2:genfs_ext2;);
                      6:(ext3:genfs_ext3;);
                      7:(ext4:genfs_ext4;);
                      8:(btrfs:genfs_btrfs;);
                      end;
     genfs_path=packed record
                IsFile:array of Boolean;
                FilePath:array of Unicodestring;
                count:SizeUint;
                end;
     genfs_inner_path=packed record
                      FileClass:array of byte;
                      FilePath:array of UnicodeString;
                      FileOffset:array of SizeUint;
                      FileDirSize:array of SizeUint;
                      Count:SizeUint;
                      {FileShortPath,FileShortStr are
                      Only for FAT File System,if the file system is not FAT,it is ignored}
                      FileFree:array of boolean;
                      FileIsShort:array of boolean;
                      FileShortStr:array of string;
                      end;
     genfs_path_string=packed record
                       path:array of UnicodeString;
                       count:SizeUint;
                       end;
     genfs_index_list=packed record
                      index:array of SizeUint;
                      count:SizeUint;
                      end;

function StringToUnicodeString(str:string):UnicodeString;
operator := (x:byte)res:genfs_variant;
operator := (x:word)res:genfs_variant;
operator := (x:dword)res:genfs_variant;
operator := (x:qword)res:genfs_variant;
operator := (x:smallint)res:genfs_variant;
operator := (x:shortint)res:genfs_variant;
operator := (x:Integer)res:genfs_variant;
operator := (x:Int64)res:genfs_variant;
function genfs_filesystem_create(fn:UnicodeString;fstype:byte;Size:SizeUint;param:array of genfs_variant):genfs_filesystem;
function genfs_filesystem_read(fn:UnicodeString):genfs_filesystem;
procedure genfs_filesystem_add(var fs:genfs_filesystem;srcpath:UnicodeString;indestpath:UnicodeString);
procedure genfs_filesystem_delete(var fs:genfs_filesystem;delpath:UnicodeString);
procedure genfs_filesystem_extract(fs:genfs_filesystem;srcpath:UnicodeString;destpath:UnicodeString);
procedure genfs_filesystem_free(var fs:genfs_filesystem);
function genfs_is_mask(detectstr:UnicodeString):boolean;

implementation

{For UnicodeString To PWideChar}
function UnicodeStringToPWideChar(str:UnicodeString):PWideChar;
var i:SizeUint;
begin
 Result:=allocmem(sizeof(WideChar)*(length(str)+1));
 i:=1;
 while(i<=length(str))do
  begin
   (Result+i-1)^:=str[i];
   inc(i);
  end;
end;
{For String To UnicodeString}
function StringToUnicodeString(str:string):UnicodeString;
var i:SizeUint;
begin
 SetLength(Result,length(str));
 for i:=1 to length(str) do Result[i]:=str[i];
end;
{For UnicodeString To String}
function UnicodeStringToString(str:Unicodestring):String;
var i,len:SizeUint;
    tempnum,ii1,ii2:Word;
begin
 len:=0;
 for i:=1 to length(str) do
  begin
   inc(len);
   SetLength(Result,len);
   if(str[i]>#127) then
    begin
     inc(len);
     SetLength(Result,len);
     tempnum:=Word(str[i]);
     ii1:=tempnum shr 8;
     ii2:=tempnum shl 8 shr 8;
     Result[len]:=Char(ii1);
     Result[len-1]:=Char(ii2);
    end
   else if(str[i]<=#127) then
    begin
     Result[len]:=str[i];
    end;
  end;
end;
{For Data Translation}
operator := (x:byte)res:genfs_variant;
begin
 res.vartype:=genfs_var_byte;
 res.genfs_byte:=x;
end;
operator := (x:word)res:genfs_variant;
begin
 res.vartype:=genfs_var_word;
 res.genfs_word:=x;
end;
operator := (x:dword)res:genfs_variant;
begin
 res.vartype:=genfs_var_dword;
 res.genfs_dword:=x;
end;
operator := (x:qword)res:genfs_variant;
begin
 res.vartype:=genfs_var_qword;
 res.genfs_qword:=x;
end;
operator := (x:smallint)res:genfs_variant;
begin
 res.vartype:=genfs_var_smallint;
 res.genfs_smallint:=x;
end;
operator := (x:shortint)res:genfs_variant;
begin
 res.vartype:=genfs_var_shortint;
 res.genfs_shortint:=x;
end;
operator := (x:Integer)res:genfs_variant;
begin
 res.vartype:=genfs_var_integer;
 res.genfs_integer:=x;
end;
operator := (x:Int64)res:genfs_variant;
begin
 res.vartype:=genfs_var_int64;
 res.genfs_int64:=x;
end;
{Total Size is in Bytes,the program will translate all other unit such as KiB to the B}
function genfs_create_empty_image(fn:UnicodeString;TotalSize:SizeUint):genfs_filesystem;
var content:array[1..1024] of byte;
    f:TFileStream;
    i:SizeUint;
begin
 for i:=1 to 1024 do content[i]:=0;
 f:=TFileStream.Create(UnicodeStringToString(fn),fmCreate);
 f.Seek(0,0);
 for i:=1 to TotalSize shr 10 do f.Write(content,1024);
 f.Free;
 Result.linkfilename:=fn;
end;
{Delete the image}
procedure genfs_delete_image(fs:genfs_filesystem);
begin
 DeleteFile(fs.linkfilename);
end;
{Reset the image}
procedure genfs_clear_image(fs:genfs_filesystem);
var content:array[1..1024] of byte;
    f:TFileStream;
    i:SizeUint;
begin
 for i:=1 to 1024 do content[i]:=0;
 f:=TFileStream.Create(UnicodeStringToString(fs.linkfilename),fmOpenWrite);
 f.Seek(0,0);
 for i:=1 to f.Size shr 10 do f.Write(content,1024);
 f.Free;
end;
{Standard I/O writing}
procedure genfs_io_write(fs:genfs_filesystem;const source;offset:SizeUint;Size:SizeUint);
var f:TFileStream;
    i:SizeUint;
begin
 if(Size=0) then exit;
 if(FileExists(fs.linkfilename)) then
 f:=TFileStream.Create(UnicodeStringToString(fs.linkfilename),fmOpenWrite)
 else
 f:=TFileStream.Create(UnicodeStringToString(fs.linkfilename),fmCreate);
 f.Seek(offset,0);
 for i:=1 to Size do
  begin
   f.Write(PByte(@Source+i-1)^,1);
  end;
 f.Free;
end;
{Standard I/O reading}
procedure genfs_io_read(fs:genfs_filesystem;var dest;offset:SizeUint;Size:SizeUint);
var f:TFileStream;
    i:SizeUint;
begin
 if(Size=0) then exit;
 f:=TFileStream.Create(UnicodeStringToString(fs.linkfilename),fmOpenRead);
 f.Seek(offset,0);
 for i:=1 to Size do
  begin
   f.Read(PByte(@dest+i-1)^,1);
  end;
 f.free;
end;
{Standard external I/O Reading}
procedure genfs_external_io_read(fn:UnicodeString;var dest;offset:SizeUint;Size:SizeUint);
var f:TFileStream;
    i:SizeInt;
begin
 if(Size=0) then exit;
 f:=TFileStream.Create(UnicodeStringToString(fn),fmOpenRead);
 f.Seek(offset,0);
 for i:=1 to Size do
  begin
   f.Read(PByte(@dest+i-1)^,1);
  end;
 f.free;
end;
{Standard external I/O Writing}
procedure genfs_external_io_write(fn:UnicodeString;const src;offset:SizeUint;Size:SizeUint);
var f:TFileStream;
    i:SizeUint;
begin
 if(Size=0) then exit;
 if(FileExists(fn)) then
 f:=TFileStream.Create(UnicodeStringToString(fn),fmOpenWrite)
 else
 f:=TFileStream.Create(UnicodeStringToString(fn),fmCreate);
 f.Seek(offset,0);
 for i:=1 to Size do
  begin
   f.Write(PByte(@src+i-1)^,1);
  end;
 f.free;
end;
{Standard external Size}
function genfs_external_file_Size(fn:UnicodeString):SizeUint;
var f:TFileStream;
    i:SizeUint;
begin
 f:=TFileStream.Create(UnicodeStringToString(fn),fmOpenRead);
 Result:=f.Size;
 f.free;
end;
{Standard initializion}
procedure genfs_filesystem_initialize(var dest);
var i:SizeUint;
begin
 for i:=sizeof(Unicodestring)+sizeof(Byte)+1 to sizeof(genfs_filesystem) do PByte(@dest+i-1)^:=0;
end;
{Standard File System Checker}
function genfs_filesystem_get_type(fs:genfs_filesystem):byte;
var regblock:array[1..512] of char;
    f:TFileStream;
begin
 f:=TFileStream.Create(UnicodeStringToString(fs.linkfilename),fmOpenRead);
 f.Seek(0,0);
 f.Read(regblock,512);
 if(regblock[$37]='F') and (regblock[$38]='A') and (regblock[$39]='T') then
  begin
   if(regblock[$40]='1') and (regblock[$41]='2') then Result:=filesystem_fat12
   else if(regblock[$40]='1') and (regblock[$41]='6') then Result:=filesystem_fat16
   else
    begin
     writeln('ERROR:Unrecognize FAT16 or FAT16 file system.');
     readln;
     abort;
    end;
  end
 else if(regblock[$53]='F') and (regblock[$54]='A') and (regblock[$55]='T')
 and (regblock[$56]='3') and (regblock[$57]='2') then
  begin
   Result:=filesystem_fat32;
  end
 else if(regblock[$4]='E') and (regblock[$54]='X') and (regblock[$55]='F')
 and (regblock[$7]='A') and (regblock[$8]='T') then
  begin
   Result:=filesystem_exfat;
  end
 else if(regblock[$4]='N') and (regblock[$54]='T') and (regblock[$55]='F')
 and (regblock[$7]='S') then
  begin
   Result:=filesystem_ntfs;
  end
 else if(Pword(@regblock[$39])^=$EF53) then
  begin
   if(Pword(@regblock[$65])^=$0) then
   Result:=filesystem_ext2
   else if(Pword(@regblock[$65])^=$0004) then
   Result:=filesystem_ext3
   else if(Pword(@regblock[$65])^=$1000) then
   Result:=filesystem_ext4;
  end
 else if(regblock[$41]='_') and (regblock[$42]='B') and (regblock[$43]='H')
 and (regblock[$44]='R') and (regblock[$45]='f') and (regblock[$46]='S')
 and (regblock[$47]='_') and (regblock[$48]='M') then
  begin
   Result:=filesystem_btrfs;
  end
 else
  begin
   writeln('ERROR:Unrecognized file system.');
   readln;
   abort;
  end;
 f.Free;
end;
{FAT File System Volume Id Calculator}
function genfs_date_to_fat_date:fat_date;
var year,month,day:word;
begin
 DecodeDate(Now,year,month,day);
 Result.CountOfYear:=year-1980;
 Result.DayOfMonth:=day;
 Result.MonthOfYear:=month;
end;
function genfs_time_to_fat_time:fat_time;
var hour,minute,second,millisecond:word;
begin
 DecodeTime(Now,hour,minute,second,millisecond);
 Result.ElapsedSeconds:=second shl 1;
 Result.Hours:=hour;
 Result.Minutes:=minute;
end;
function genfs_generate_volume_id:dword;
begin
 Result:=Pword(@genfs_date_to_fat_date)^ shl 16+Pword(@genfs_time_to_fat_time)^;
end;
{FAT Extract Short File Name}
function genfs_fat_extract_short_name(struct:fat_directory_structure):string;
var i:SizeInt;
begin
 Result:='';
 for i:=1 to 8 do
  begin
   if(struct.directoryname[i]<=' ') then break;
   Result:=Result+struct.directoryname[i];
  end;
 if(struct.directoryext[1]>' ') then
  begin
   Result:=Result+'.';
   for i:=1 to 3 do
    begin
     if(struct.directoryext[i]<=' ') then break;
     Result:=Result+struct.directoryext[i];
    end;
  end;
end;
{File System Infomation Write}
procedure genfs_write(fs:genfs_filesystem;init:boolean=false);
var i,tempnum1,tempnum2,tempnum3,tempnum4,tempnum5,tempnum6:SizeUint;
begin
 if(fs.fsname=filesystem_fat12) then
  begin
   genfs_io_write(fs,fs.fat12.header,0,sizeof(fat_header));
   tempnum1:=fs.fat12.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat12.header.head.bpb_SectorPerCluster;
   tempnum3:=fs.fat12.header.head.bpb_FatSectorCount16;
   tempnum4:=fs.fat12.header.head.bpb_ReservedSectorCount;
   for i:=1 to fs.fat12.entrycount do
    begin
     if(init) and (i>1) then break;
     genfs_io_write(fs,(fs.fat12.entrypair+i-1)^,
     tempnum4*tempnum1+(i-1)*sizeof(fat12_entry_pair),
     sizeof(fat12_entry_pair));
     genfs_io_write(fs,(fs.fat12.entrypair+i-1)^,
     (tempnum4+tempnum3)*tempnum1+(i-1)*sizeof(fat12_entry_pair),
     sizeof(fat12_entry_pair));
    end;
  end
 else if(fs.fsname=filesystem_fat16) then
  begin
   genfs_io_write(fs,fs.fat16.header,0,sizeof(fat_header));
   tempnum1:=fs.fat16.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat16.header.head.bpb_SectorPerCluster;
   tempnum3:=fs.fat16.header.head.bpb_FatSectorCount16;
   tempnum4:=fs.fat16.header.head.bpb_ReservedSectorCount;
   for i:=1 to fs.fat16.entrycount do
    begin
     if(init) and (i>1) then break;
     genfs_io_write(fs,(fs.fat16.entrypair+i-1)^,
     tempnum4*tempnum1+(i-1)*sizeof(fat16_entry_pair),
     sizeof(fat16_entry_pair));
     genfs_io_write(fs,(fs.fat16.entrypair+i-1)^,
     (tempnum4+tempnum3)*tempnum1+(i-1)*sizeof(fat16_entry_pair),
     sizeof(fat16_entry_pair));
    end;
  end
 else if(fs.fsname=filesystem_fat32) then
  begin
   genfs_io_write(fs,fs.fat32.header,0,sizeof(fat32_header));
   tempnum6:=fs.fat32.header.exthead.bpb_backupBootSector;
   tempnum5:=fs.fat32.header.exthead.bpb_filesysteminfo;
   tempnum1:=fs.fat32.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat32.header.head.bpb_SectorPerCluster;
   tempnum3:=fs.fat32.header.exthead.bpb_FatSectorCount32;
   tempnum4:=fs.fat32.header.head.bpb_ReservedSectorCount;
   genfs_io_write(fs,fs.fat32.header,tempnum6*tempnum1,sizeof(fat32_header));
   genfs_io_write(fs,fs.fat32.fsinfo,tempnum5*tempnum1,sizeof(fat_fsinfo_structure));
   for i:=1 to fs.fat32.entrycount do
    begin
     if(init) and (i>1) then break;
     genfs_io_write(fs,(fs.fat32.entrypair+i-1)^,
     tempnum4*tempnum1+(i-1)*sizeof(fat32_entry_pair),
     sizeof(fat32_entry_pair));
     genfs_io_write(fs,(fs.fat32.entrypair+i-1)^,
     (tempnum4+tempnum3)*tempnum1+(i-1)*sizeof(fat32_entry_pair),
     sizeof(fat32_entry_pair));
    end;
  end
 else
  begin

  end;
end;
{File System create}
function genfs_filesystem_create(fn:UnicodeString;fstype:byte;Size:SizeUint;param:array of genfs_variant):genfs_filesystem;
begin
 {Pass the genfs's corresponding file name in disk}
 Result.linkfilename:=fn;
 {Initialize the file}
 genfs_create_empty_image(Result.linkfilename,Size shl 20);
 {Specify the genfs file system type}
 Result.fsname:=fstype;
 {Initialize the genfs filesystem record}
 genfs_filesystem_initialize(Result);
 {Initialize the genfs specific filesystem}
 if(fstype=filesystem_fat12) then
  begin
   {Need parameter:BytePerSector,SectorPerCluster,ReservedSectorCount,FATSectorCount16}
   Result.fat12.header.head.bpb_bytesPerSector:=param[0].genfs_word;
   Result.fat12.header.head.bpb_SectorPerCluster:=param[1].genfs_byte;
   Result.fat12.header.head.bpb_ReservedSectorCount:=param[2].genfs_word;
   Result.fat12.header.head.bpb_FatSectorCount16:=param[3].genfs_word;
   Result.fat12.header.head.bpb_TotalSector16:=Size shl 20 div param[0].genfs_word;
   Result.fat12.header.head.bpb_TotalSector32:=0;
   Result.fat12.fatbit:=12;
   {Other universal parameters}
   fat_jump_boot_move(Result.fat12.header.head.bpb_jumpboot);
   fat_oem_name_move(Result.fat12.header.head.bpb_oemname);
   Result.fat12.header.head.bpb_RootEntryCount:=512;
   Result.fat12.header.head.bpb_media:=$F8;
   Result.fat12.header.head.bpb_NumberOfFATS:=2;
   Result.fat12.header.head.bpb_SectorsPerTrack:=2;
   Result.fat12.header.head.bpb_NumberOfHeads:=8;
   Result.fat12.header.head.bpb_HiddenSector:=0;
   {FAT12 extended header initalization}
   Result.fat12.header.exthead.bs_bootsig:=$29;
   Result.fat12.header.exthead.bs_driver_number:=$80;
   Result.fat12.header.exthead.bs_volume_id:=genfs_generate_volume_id;
   fat_default_volume_label_move(Result.fat12.header.exthead.bs_volume_label);
   fat_default_file_system_type_move(12,Result.fat12.header.exthead.bs_filesystem_type);
   Result.fat12.header.exthead.bs_signature:=$AA55;
   {FAT12 entry initialization}
   Result.fat12.entrypair:=allocmem(param[3].genfs_word*param[0].genfs_word div 3*sizeof(fat_entry_pair));
   Result.fat12.entrypair^.entry12.entry1:=$FF8;
   Result.fat12.entrypair^.entry12.entry2:=$C00;
   Result.fat12.entrycount:=param[3].genfs_word*param[0].genfs_word div 3;
   {FAT12 data position initialization}
   Result.fat12.datastart:=param[0].genfs_word*(param[2].genfs_word+param[3].genfs_word*2);
  end
 else if(fstype=filesystem_fat16) then
  begin
   {Need parameter:BytePerSector,SectorPerCluster,ReservedSectorCount,FATSectorCount16}
   Result.fat16.header.head.bpb_bytesPerSector:=param[0].genfs_word;
   Result.fat16.header.head.bpb_SectorPerCluster:=param[1].genfs_byte;
   Result.fat16.header.head.bpb_ReservedSectorCount:=param[2].genfs_word;
   Result.fat16.header.head.bpb_FatSectorCount16:=param[3].genfs_word;
   Result.fat16.header.head.bpb_TotalSector16:=Size shl 20 div param[0].genfs_word;
   Result.fat16.header.head.bpb_TotalSector32:=0;
   Result.fat16.fatbit:=16;
   {Other universal parameters}
   fat_jump_boot_move(Result.fat16.header.head.bpb_jumpboot);
   fat_oem_name_move(Result.fat16.header.head.bpb_oemname);
   Result.fat16.header.head.bpb_RootEntryCount:=512;
   Result.fat16.header.head.bpb_media:=$F8;
   Result.fat16.header.head.bpb_NumberOfFATS:=2;
   Result.fat16.header.head.bpb_SectorsPerTrack:=2;
   Result.fat16.header.head.bpb_NumberOfHeads:=8;
   Result.fat16.header.head.bpb_HiddenSector:=0;
   {FAT16 extended header initalization}
   Result.fat16.header.exthead.bs_bootsig:=$29;
   Result.fat16.header.exthead.bs_driver_number:=$80;
   Result.fat16.header.exthead.bs_volume_id:=genfs_generate_volume_id;
   fat_default_volume_label_move(Result.fat16.header.exthead.bs_volume_label);
   fat_default_file_system_type_move(16,Result.fat16.header.exthead.bs_filesystem_type);
   Result.fat16.header.exthead.bs_signature:=$AA55;
   {FAT16 entry initialization}
   Result.fat16.entrypair:=allocmem(param[3].genfs_word*param[0].genfs_word shr 2*sizeof(fat_entry_pair));
   Result.fat16.entrypair^.entry16[1]:=$FFF8;
   Result.fat16.entrypair^.entry16[2]:=$C000;
   Result.fat16.entrycount:=param[3].genfs_word*param[0].genfs_word shr 2;
   {FAT16 data position initialization}
   Result.fat16.datastart:=param[0].genfs_word*(param[2].genfs_word+param[3].genfs_word*2);
  end
 else if(fstype=filesystem_fat32) then
  begin
   {Need paramater:BytesPerSector,SectorPerCluster,ReservedSectorCount,
   FATSector32,BackupBootSector,FileSystemInfo,RootCluster}
   Result.fat32.header.head.bpb_bytesPerSector:=param[0].genfs_word;
   Result.fat32.header.head.bpb_SectorPerCluster:=param[1].genfs_byte;
   Result.fat32.header.head.bpb_ReservedSectorCount:=param[2].genfs_word;
   Result.fat32.header.head.bpb_FatSectorCount16:=0;
   Result.fat32.header.exthead.bpb_FatSectorCount32:=param[3].genfs_dword;
   Result.fat32.header.head.bpb_TotalSector32:=Size shl 20 div param[0].genfs_word;
   Result.fat32.header.exthead.bpb_backupBootSector:=param[4].genfs_word;
   Result.fat32.header.exthead.bpb_filesysteminfo:=param[5].genfs_word;
   Result.fat32.header.exthead.bpb_rootcluster:=param[6].genfs_dword;
   {Other universial parameters}
   fat_jump_boot_move(Result.fat32.header.head.bpb_jumpboot);
   fat_oem_name_move(Result.fat32.header.head.bpb_oemname);
   Result.fat32.header.head.bpb_RootEntryCount:=0;
   Result.fat32.header.head.bpb_media:=$F8;
   Result.fat32.header.head.bpb_NumberOfFATS:=2;
   Result.fat32.header.head.bpb_SectorsPerTrack:=2;
   Result.fat32.header.head.bpb_NumberOfHeads:=8;
   Result.fat32.header.head.bpb_HiddenSector:=0;
   {FAT32 extended header initialization}
   Result.fat32.header.exthead.bs_bootsig:=$29;
   Result.fat32.header.exthead.bs_driver_number:=$80;
   Result.fat32.header.exthead.bs_volume_id:=genfs_generate_volume_id;
   fat_default_volume_label_move(Result.fat32.header.exthead.bs_volume_label);
   fat_default_file_system_type_move(32,Result.fat32.header.exthead.bs_filesystem_type);
   Result.fat32.header.exthead.bs_signature:=$AA55;
   Result.fat32.header.exthead.bpb_ExtendedFlags.FATmirrordisable:=0;
   Result.fat32.header.exthead.bpb_ExtendedFlags.NumberOfActiveFAT:=0;
   {FAT32 entry initialization}
   Result.fat32.entrypair:=allocmem(param[3].genfs_word*param[0].genfs_word shr 3*sizeof(fat_entry_pair));
   Result.fat32.entrypair^.entry32[1]:=$FFFFFF8;
   Result.fat32.entrypair^.entry32[2]:=$0C00000;
   Result.fat32.entrycount:=param[3].genfs_word*param[0].genfs_word shr 3;
   {FAT32 data position initialization}
   Result.fat32.datastart:=param[0].genfs_word*(param[2].genfs_word+param[3].genfs_word*2);
   {FAT32 file system info initialization}
   Result.fat32.fsinfo.leadsignature:=fat32_lead_signature;
   Result.fat32.fsinfo.structsignature:=fat32_struct_signature;
   Result.fat32.fsinfo.trailsignature:=fat32_trail_signature;
   Result.fat32.fsinfo.nextfree:=param[4].genfs_word;
   Result.fat32.fsinfo.freecount:=
   (Size shl 20 div param[0].genfs_word-2*param[3].genfs_dword-param[2].genfs_word)
   div (param[0].genfs_word*param[1].genfs_byte);
  end
 else
  begin

  end;
 genfs_write(Result,true);
end;
{File System Read and recognize}
function genfs_filesystem_read(fn:UnicodeString):genfs_filesystem;
var i:SizeUint;
    tempnum1,tempnum2,tempnum3:SizeUint;
    {For FAT File System Only}
    fatentry:fat_entry_pair;
begin
 {Pass the genfs's corresponding file name in disk}
 Result.linkfilename:=fn;
 {Check the image file's file system name}
 Result.fsname:=genfs_filesystem_get_type(Result);
 {Initialize the genfs filesystem record}
 genfs_filesystem_initialize(Result);
 {Initialize the genfs specific system}
 if(Result.fsname=filesystem_fat12) then
  begin
   {Read the FAT12 Header}
   genfs_io_read(Result,Result.fat12.header,0,sizeof(fat_header));
   tempnum1:=Result.fat12.header.head.bpb_ReservedSectorCount;
   tempnum2:=Result.fat12.header.head.bpb_FatSectorCount16;
   tempnum3:=Result.fat12.header.head.bpb_bytesPerSector;
   Result.fat12.fatbit:=12;
   {Read the FAT12 entry}
   Result.fat12.entrypair:=allocmem(tempnum2*tempnum3);
   i:=1;
   while(i<=tempnum2*tempnum3 div sizeof(fat12_entry_pair)) do
    begin
     genfs_io_read(Result,(Result.fat12.entrypair+i-1)^,tempnum1*tempnum3+
     (i-1)*sizeof(fat12_entry_pair),sizeof(fat12_entry_pair));
     genfs_io_read(Result,fatentry,(tempnum1+tempnum2)*tempnum3+
     (i-1)*sizeof(fat12_entry_pair),sizeof(fat12_entry_pair));
     if((Result.fat12.entrypair+i-1)^.entry12.entry1<>fatentry.entry12.entry1)
     or((Result.fat12.entrypair+i-1)^.entry12.entry2<>fatentry.entry12.entry2) then
     (Result.fat12.entrypair+i-1)^:=fatentry;
     inc(i);
    end;
   Result.fat12.entrycount:=tempnum2*tempnum3 div sizeof(fat12_entry_pair);
   {Calculate the data start position}
   Result.fat12.datastart:=(tempnum1+tempnum2*2)*tempnum3;
  end
 else if(Result.fsname=filesystem_fat16) then
  begin
   {Read the FAT16 header}
   genfs_io_read(Result,Result.fat16.header,0,sizeof(fat_header));
   tempnum1:=Result.fat16.header.head.bpb_ReservedSectorCount;
   tempnum2:=Result.fat16.header.head.bpb_FatSectorCount16;
   tempnum3:=Result.fat16.header.head.bpb_bytesPerSector;
   Result.fat16.fatbit:=16;
   {Read the FAT16 entry}
   Result.fat16.entrypair:=allocmem(tempnum2*tempnum3);
   i:=1;
   while(i<=tempnum2*tempnum3 div sizeof(fat16_entry_pair)) do
    begin
     genfs_io_read(Result,(Result.fat16.entrypair+i-1)^,tempnum1*tempnum3+
     (i-1)*sizeof(fat16_entry_pair),sizeof(fat16_entry_pair));
     genfs_io_read(Result,fatentry,(tempnum1+tempnum2)*tempnum3+
     (i-1)*sizeof(fat16_entry_pair),sizeof(fat16_entry_pair));
     if((Result.fat16.entrypair+i-1)^.entry16[1]<>fatentry.entry16[1])
     or((Result.fat16.entrypair+i-1)^.entry16[2]<>fatentry.entry16[2]) then
     (Result.fat16.entrypair+i-1)^:=fatentry;
     inc(i);
    end;
   Result.fat16.entrycount:=tempnum2*tempnum3 div sizeof(fat16_entry_pair);
   {Calculate the data start position}
   Result.fat16.datastart:=(tempnum1+tempnum2*2)*tempnum3;
  end
 else if(Result.fsname=filesystem_fat32) then
  begin
   {Read the FAT32 header}
   genfs_io_read(Result,Result.fat32.header,0,sizeof(fat32_header));
   tempnum1:=Result.fat32.header.head.bpb_ReservedSectorCount;
   tempnum2:=Result.fat32.header.exthead.bpb_FatSectorCount32;
   tempnum3:=Result.fat32.header.head.bpb_bytesPerSector;
   if(Result.fat32.header.head.bpb_jumpboot[1]<>$EB) or
   (Result.fat32.header.head.bpb_jumpboot[2]<>$58) or
   (Result.fat32.header.head.bpb_jumpboot[3]<>$90) then
    begin
     genfs_io_read(Result,Result.fat32.header,
     Result.fat32.header.exthead.bpb_backupBootSector*tempnum3,sizeof(fat32_header));
     genfs_io_write(Result,Result.fat32.header,0,sizeof(fat32_header));
    end;
   {Read the FAT32 FileSystemInfo}
   genfs_io_read(Result,Result.fat32.fsinfo,
   Result.fat32.header.exthead.bpb_filesysteminfo*tempnum3,sizeof(fat_fsinfo_structure));
   {Read the FAT32 entry}
   i:=1;
   Result.fat32.entrypair:=allocmem(tempnum2*tempnum3);
   while(i<=tempnum2*tempnum3 div sizeof(fat32_entry_pair)) do
    begin
     genfs_io_read(Result,(Result.fat32.entrypair+i-1)^,tempnum1*tempnum3+
     (i-1)*sizeof(fat32_entry_pair),sizeof(fat32_entry_pair));
     genfs_io_read(Result,fatentry,(tempnum1+tempnum2)*tempnum3+
     (i-1)*sizeof(fat32_entry_pair),sizeof(fat32_entry_pair));
     if((Result.fat32.entrypair+i-1)^.entry32[1]<>fatentry.entry32[1])
     or((Result.fat32.entrypair+i-1)^.entry32[2]<>fatentry.entry32[2]) then
     (Result.fat32.entrypair+i-1)^:=fatentry;
     inc(i);
    end;
   Result.fat32.entrycount:=tempnum2*tempnum3 div sizeof(fat32_entry_pair);
   {Calculate the FAT32 data start}
   Result.fat32.datastart:=(tempnum1+tempnum2*2)*tempnum3;
  end
 else
  begin

  end;
end;
{File System Free}
procedure genfs_filesystem_free(var fs:genfs_filesystem);
begin
 if(fs.fsname=filesystem_fat12) then
  begin
   fs.fsname:=9;
   FreeMem(fs.fat12.entrypair);
   fs.fat12.entrycount:=0;
  end
 else if(fs.fsname=filesystem_fat16) then
  begin
   fs.fsname:=9;
   FreeMem(fs.fat16.entrypair);
   fs.fat16.entrycount:=0;
  end
 else if(fs.fsname=filesystem_fat32) then
  begin
   fs.fsname:=9;
   FreeMem(fs.fat32.entrypair);
   fs.fat32.entrycount:=0;
  end
 else
  begin

  end;
end;
{Mask match for GenFs program}
function genfs_is_mask(detectstr:UnicodeString):boolean;
var i,len:SizeUint;
begin
 i:=1; len:=length(detectstr);
 while(i<=len) do
  begin
   if(detectstr[i]='?') or (detectstr[i]='*') then break;
   inc(i);
  end;
 if(i<=len) then Result:=true else Result:=false;
end;
function genfs_mask_match(mask:UnicodeString;detectstr:UnicodeString):boolean;
var i,j,len1,len2:SizeUint;
begin
 i:=1; j:=1; len1:=length(mask); len2:=length(detectstr);
 while(i<=len1) and (j<=len2) do
  begin
   if(mask[i]='*') then
    begin
     if(i<len1) and (mask[i+1]='*') then
      begin
       inc(i);
      end
     else if(i<len1) and (mask[i+1]='?') then
      begin
       inc(i);
      end
     else if(detectstr[j]<>#0) and (mask[i+1]=detectstr[j]) then
      begin
       inc(i); inc(j);
      end
     else inc(j);
    end
   else if(mask[i]='?') then
    begin
     if(detectstr[j]<>#0) then
      begin
       inc(i); inc(j);
      end
     else break;
    end
   else
    begin
     if(mask[i]=detectstr[j]) then
      begin
       inc(i); inc(j);
      end
     else break;
    end;
  end;
 if(j>len2) then Result:=true else Result:=false;
end;
{External File System detection}
function genfs_search_for_path_external(basedir:UnicodeString;ismask:boolean):genfs_path;
var SearchRec:TUnicodeSearchRec;
    Order:Longint;
    bool:boolean;
    tempstr:UnicodeString;
    temppath:genfs_path;
    i:SizeUint;
begin
 Result.count:=0; Order:=0; bool:=false;
 if(FileExists(basedir)) then
  begin
   inc(Result.count);
   SetLength(Result.FilePath,Result.count);
   SetLength(Result.IsFile,Result.count);
   Result.FilePath[Result.count-1]:=basedir;
   Result.IsFile[Result.count-1]:=true;
  end;
 repeat
  begin
   if(bool=false) and (ismask=false) then
   Order:=FindFirst(basedir+'/*',faDirectory,SearchRec)
   else if(bool=false) and (ismask) then
   Order:=FindFirst(basedir,faDirectory,SearchRec)
   else Order:=FindNext(SearchRec);
   bool:=true;
   if(DirectoryExists(basedir+'/'+SearchRec.Name)=false) then break;
   if(SearchRec.Name='..') or (SearchRec.Name='.') then continue;
   if(Order<>0) then break;
   tempstr:=BaseDir+'/'+SearchRec.Name;
   inc(Result.count);
   SetLength(Result.FilePath,Result.count);
   SetLength(Result.IsFile,Result.count);
   Result.FilePath[Result.count-1]:=tempstr;
   Result.IsFile[Result.count-1]:=false;
   temppath:=genfs_search_for_path_external(tempstr,ismask);
   for i:=1 to temppath.count do
    begin
     inc(Result.count);
     SetLength(Result.FilePath,Result.count);
     SetLength(Result.IsFile,Result.count);
     Result.FilePath[Result.count-1]:=temppath.FilePath[i-1];
     Result.IsFile[Result.count-1]:=temppath.IsFile[i-1];
    end;
  end
 until (Order<>0);
 FindClose(SearchRec);
 bool:=false; Order:=0;
 repeat
  begin
   if(bool=false) and (ismask=false) then
   Order:=FindFirst(basedir+'/*',faAnyFile,SearchRec)
   else if(bool=false) and (ismask) then
   Order:=FindFirst(basedir,faAnyFile,SearchRec)
   else Order:=FindNext(SearchRec);
   bool:=true;
   if(FileExists(basedir+'/'+SearchRec.Name)) then continue;
   if(SearchRec.Name='..') or (SearchRec.Name='.') then continue;
   if(SearchRec.Attr and faDirectory=faDirectory) then continue;
   if(Order<>0) then break;
   inc(Result.count);
   tempstr:=basedir+'/'+SearchRec.Name;
   SetLength(Result.FilePath,Result.count);
   SetLength(Result.IsFile,Result.count);
   Result.FilePath[Result.count-1]:=tempstr;
   Result.IsFile[Result.count-1]:=true;
  end
 until (Order<>0);
 FindClose(SearchRec);
end;
{GenFs File Path Prefix}
function genfs_check_prefix(prevpath,nextpath:UnicodeString;isnextdir:Boolean=false):boolean;
var i,len,len2:SizeUint;
begin
 if(length(prevpath)>length(nextpath)) then
  begin
   genfs_check_prefix:=false;
  end
 else
  begin
   len:=length(prevpath); len2:=length(nextpath); i:=1;
   while(i<=len)do
    begin
     if(prevpath[i]<>nextpath[i]) then break;
     inc(i);
    end;
   inc(i,2);
   while(i<=len2) and (isnextdir) do
    begin
     if(nextpath[i]='/') or (nextpath[i]='\') then break;
     inc(i);
    end;
   if(i>len) and (isnextdir=false) then genfs_check_prefix:=true
   else if(i>len2) and (isnextdir) then genfs_check_prefix:=true
   else genfs_check_prefix:=false;
  end;
end;
{GenFs check the file is in the same path}
function genfs_check_same_path(path1,path2:UnicodeString):boolean;
var i,j,len1,len2:SizeUInt;
begin
 len1:=length(path1); i:=len1;
 while(i>1) and ((path1[i]<>'/') or (path1[i]<>'\')) do dec(i);
 len2:=length(path2); j:=len2;
 while(j>1) and ((path2[j]<>'/') or (path2[j]<>'\')) do dec(j);
 if(Copy(path1,1,i-1)='') and (Copy(path1,1,i-1)=Copy(path2,1,j-1)) then Result:=true else Result:=false;
end;
{File System Path Translation}
function genfs_path_to_path_string(path:Unicodestring):genfs_path_string;
var i:SizeUint;
    tempstr:Unicodestring;
begin
 i:=1; tempstr:=path;
 Result.count:=0; SetLength(Result.path,1);
 while(length(tempstr)>0)do
  begin
   if(tempstr[i]='/') or (tempstr[i]='\') then
    begin
     if(i>1) then
      begin
       inc(Result.count);
       SetLength(Result.path,Result.count);
       Result.path[Result.count-1]:=Copy(tempstr,1,i-1);
      end;
     Delete(tempstr,1,i); i:=1; continue;
    end;
   inc(i);
  end;
end;
{Detect the file and directory in image}
function genfs_search_for_path(fs:genfs_filesystem;
basedir:Unicodestring;startoffset:SizeUint=0;Subdir:boolean=true):genfs_inner_path;
var fatstr:fat_string;
    tempstr:PWideChar;
    temppath:genfs_inner_path;
    i,offset,offset2,tempnum,tempnum2,ii1,ii2:SizeUint;
    detectcontent:array[1..32] of Byte;
    bool:boolean;
    {If the search path is not on Root Directory,pathstr is used}
    pathstr:genfs_path_string;
    index:SizeUint;
begin
 i:=1; Result.Count:=0;
 SetLength(Result.FilePath,0); SetLength(Result.FileClass,0);
 SetLength(Result.FileIsShort,0); SetLength(Result.FileFree,0);
 SetLength(Result.FileDirSize,0); SetLength(Result.FileOffset,0);
 if(fs.fsname=filesystem_fat12) then
  begin
   offset2:=0;
   if(basedir='/') or (basedir='\') then
    begin
     offset:=0; fatstr.unicodefn:=nil; fatstr.unicodefncount:=0; bool:=false;
     while(True)do
      begin
       genfs_io_read(fs,detectcontent,fs.fat12.datastart+offset,sizeof(fat_directory_structure));
       if(detectcontent[1]=$00) and (bool=false) then
        begin
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         break;
        end
       else
        begin
         fat_MoveDirStructStringToFatString(Pfat_directory_structure(@detectcontent)^,fatstr);
         tempstr:=fat_FatStringToPWideChar(fatstr);
         inc(Result.Count);
         SetLength(Result.FileFree,Result.count);
         Result.FileFree[Result.count-1]:=detectcontent[1]=$E5;
         SetLength(Result.FilePath,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FilePath[Result.count-1]:=basedir+tempstr
         else Result.FilePath[Result.count-1]:='';
         SetLength(Result.FileIsShort,Result.Count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileIsShort[Result.count-1]:=true
         else Result.FileIsShort[Result.count-1]:=false;
         SetLength(Result.FileShortStr,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileShortStr[Result.count-1]:=
         genfs_fat_extract_short_name(Pfat_directory_structure(@detectcontent)^)
         else Result.FileShortStr[Result.count-1]:='';
         SetLength(Result.FileOffset,Result.count);
         Result.FileOffset[Result.count-1]:=offset;
         SetLength(Result.FileClass,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileClass[Result.count-1]:=
         fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
         else
         Result.FileClass[Result.count-1]:=0;
         SetLength(Result.FileDirSize,Result.count);
         Result.FileDirSize[Result.count-1]:=sizeof(fat_directory_structure);
         if(Result.FileClass[Result.count-1]=fat_directory_directory)
         and(UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.') and (subdir) then
          begin
           temppath:=genfs_search_for_path(fs,basedir+tempstr,
           (Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16+
           Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
           fs.fat12.header.head.bpb_SectorPerCluster*fs.fat12.header.head.bpb_bytesPerSector);
           for i:=1 to temppath.Count do
            begin
             inc(Result.Count);
             SetLength(Result.FilePath,Result.count);
             SetLength(Result.FileOffset,Result.count);
             SetLength(Result.FileClass,Result.count);
             SetLength(Result.FileDirSize,Result.count);
             SetLength(Result.FileShortStr,Result.Count);
             SetLength(Result.FileIsShort,Result.count);
             Result.FilePath[Result.count-1]:=temppath.FilePath[i-1];
             Result.FileOffset[Result.count-1]:=temppath.FileOffset[i-1];
             Result.FileClass[Result.count-1]:=temppath.FileClass[i-1];
             Result.FileDirSize[Result.count-1]:=temppath.FileDirSize[i-1];
             Result.FileShortStr[Result.Count-1]:=temppath.FileShortStr[i-1];
             Result.FileIsShort[Result.count-1]:=true;
            end;
          end;
         if(fatstr.unicodefncount>0) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         FreeMem(tempstr);
        end;
       inc(offset,sizeof(fat_directory_structure));
       tempnum:=offset div (fs.fat12.header.head.bpb_bytesPerSector*
       fs.fat12.header.head.bpb_SectorPerCluster)+2;
       tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat12.header.head.bpb_bytesPerSector*
       fs.fat12.header.head.bpb_SectorPerCluster)+2;
       if(tempnum>tempnum2) then
        begin
         ii1:=tempnum2 shr 1; ii2:=tempnum2 mod 2;
         if(ii2=0) then
          begin
           if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_using) then break
           else offset:=
           ((fs.fat12.entrypair+ii1)^.entry12.entry1-2)
           *fs.fat12.header.head.bpb_bytesPerSector*fs.fat12.header.head.bpb_SectorPerCluster;
          end
         else if(ii2=1) then
          begin
           if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)<>fat_using) then break
           else offset:=
           ((fs.fat12.entrypair+ii1)^.entry12.entry2-2)
           *fs.fat12.header.head.bpb_bytesPerSector*fs.fat12.header.head.bpb_SectorPerCluster;
          end;
        end;
      end;
    end
   else
    begin
     if(startoffset=0) then
      begin
       offset:=0; index:=1;
       pathstr:=genfs_path_to_path_string(basedir);
       fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
       while(index<=pathstr.count)do
        begin
         genfs_io_read(fs,detectcontent,fs.fat12.datastart+offset,sizeof(fat_directory_structure));
         if(detectcontent[1]=$00) and (bool=false) then
          begin
           if(fatstr.unicodefn<>nil) then
            begin
             FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
            end;
           break;
          end
         else if(detectcontent[12]<>fat_attribute_long_name) and (detectcontent[1]<>$E5) then
          begin
           fat_MoveDirStructStringToFatString(Pfat_directory_structure(@detectcontent)^,fatstr);
           tempstr:=fat_FatStringToPWideChar(fatstr);
           if(UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.')
           and(fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
           =fat_directory_directory) and (tempstr=pathstr.path[index-1]) then
            begin
             offset:=(Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16
             +Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
             fs.fat12.header.head.bpb_SectorPerCluster*fs.fat12.header.head.bpb_bytesPerSector;
             inc(index);
             if(fatstr.unicodefncount>0) then
              begin
               FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
              end;
             FreeMem(tempstr);
             continue;
            end;
           if(fatstr.unicodefncount>0) then
            begin
             FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
            end;
           FreeMem(tempstr);
          end;
         inc(offset,sizeof(fat_directory_structure));
         tempnum:=offset div (fs.fat12.header.head.bpb_bytesPerSector*
         fs.fat12.header.head.bpb_SectorPerCluster)+2;
         tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat12.header.head.bpb_bytesPerSector*
         fs.fat12.header.head.bpb_SectorPerCluster)+2;
         if(tempnum>tempnum2) then
          begin
           ii1:=tempnum2 shr 1; ii2:=tempnum2 mod 2;
           if(ii2=0) then
            begin
             if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_using) then break
             else offset:=
             ((fs.fat12.entrypair+ii1)^.entry12.entry1-2)
             *fs.fat12.header.head.bpb_bytesPerSector*fs.fat12.header.head.bpb_SectorPerCluster;
            end
           else if(ii2=1) then
            begin
             if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)<>fat_using) then break
             else offset:=
             ((fs.fat12.entrypair+ii1)^.entry12.entry2-2)
             *fs.fat12.header.head.bpb_bytesPerSector*fs.fat12.header.head.bpb_SectorPerCluster;
            end;
          end;
        end;
      end
     else offset:=startoffset;
     fatstr.unicodefn:=nil; fatstr.unicodefncount:=0; bool:=false;
     while(True)do
      begin
       genfs_io_read(fs,detectcontent,fs.fat12.datastart+offset,sizeof(fat_directory_structure));
       if(detectcontent[1]=$00) and (bool=false) then
        begin
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         break;
        end
       else if(detectcontent[12]<>fat_attribute_long_name) then
        begin
         fat_MoveDirStructStringToFatString(Pfat_directory_structure(@detectcontent)^,fatstr);
         tempstr:=fat_FatStringToPWideChar(fatstr);
         inc(Result.Count);
         SetLength(Result.FileFree,Result.count);
         Result.FileFree[Result.count-1]:=detectcontent[1]=$E5;
         SetLength(Result.FilePath,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FilePath[Result.count-1]:=basedir+'/'+tempstr
         else Result.FilePath[Result.count-1]:='';
         SetLength(Result.FileIsShort,Result.Count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileIsShort[Result.count-1]:=true
         else Result.FileIsShort[Result.count-1]:=false;
         SetLength(Result.FileShortStr,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileShortStr[Result.count-1]:=
         genfs_fat_extract_short_name(Pfat_directory_structure(@detectcontent)^)
         else Result.FileShortStr[Result.count-1]:='';
         Result.FileOffset[Result.count-1]:=offset;
         SetLength(Result.FileClass,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileClass[Result.count-1]:=
         fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
         else
         Result.FileClass[Result.count-1]:=0;
         SetLength(Result.FileDirSize,Result.count);
         Result.FileDirSize[Result.count-1]:=sizeof(fat_directory_structure);
         if(Result.FileClass[Result.count-1]=fat_directory_directory)
         and (Pfat_directory_structure(@detectcontent)^.directoryfilesize=0)
         and (UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.') then
          begin
           temppath:=genfs_search_for_path(fs,basedir+'/'+tempstr,
           (Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16+
           Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
           fs.fat12.header.head.bpb_SectorPerCluster*fs.fat12.header.head.bpb_bytesPerSector);
           for i:=1 to temppath.Count do
            begin
             inc(Result.Count);
             SetLength(Result.FilePath,Result.count);
             SetLength(Result.FileOffset,Result.count);
             SetLength(Result.FileClass,Result.count);
             SetLength(Result.FileDirSize,Result.count);
             SetLength(Result.FileShortStr,Result.Count);
             SetLength(Result.FileIsShort,Result.count);
             Result.FilePath[Result.count-1]:=temppath.FilePath[i-1];
             Result.FileOffset[Result.count-1]:=temppath.FileOffset[i-1];
             Result.FileClass[Result.count-1]:=temppath.FileClass[i-1];
             Result.FileDirSize[Result.count-1]:=temppath.FileDirSize[i-1];
             Result.FileShortStr[Result.Count-1]:=temppath.FileShortStr[i-1];
             Result.FileIsShort[Result.count-1]:=true;
            end;
          end;
         if(fatstr.unicodefncount>0) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         FreeMem(tempstr);
        end;
       inc(offset,sizeof(fat_directory_structure));
       tempnum:=offset div (fs.fat12.header.head.bpb_bytesPerSector*
       fs.fat12.header.head.bpb_SectorPerCluster)+2;
       tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat12.header.head.bpb_bytesPerSector*
       fs.fat12.header.head.bpb_SectorPerCluster)+2;
       if(tempnum>tempnum2) then
        begin
         ii1:=tempnum2 shr 1; ii2:=tempnum2 mod 2;
         if(ii2=0) then
          begin
           if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_using) then break
           else offset:=
           ((fs.fat12.entrypair+ii1)^.entry12.entry1-2)
           *fs.fat12.header.head.bpb_bytesPerSector*fs.fat12.header.head.bpb_SectorPerCluster;
          end
         else if(ii2=1) then
          begin
           if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)<>fat_using) then break
           else offset:=
           ((fs.fat12.entrypair+ii1)^.entry12.entry2-2)
           *fs.fat12.header.head.bpb_bytesPerSector*fs.fat12.header.head.bpb_SectorPerCluster;
          end;
        end;
      end;
    end;
  end
 else if(fs.fsname=filesystem_fat16) then
  begin
   offset2:=0;
   if(basedir='/') or (basedir='\') then
    begin
     offset:=0; fatstr.unicodefn:=nil; fatstr.unicodefncount:=0; bool:=false;
     while(True)do
      begin
       genfs_io_read(fs,detectcontent,fs.fat16.datastart+offset,sizeof(fat_directory_structure));
       if(detectcontent[1]=$00) then
        begin
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         break;
        end
       else
        begin
         inc(Result.Count);
         SetLength(Result.FileFree,Result.count);
         Result.FileFree[Result.count-1]:=detectcontent[1]=$E5;
         SetLength(Result.FilePath,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FilePath[Result.count-1]:=basedir+tempstr
         else Result.FilePath[Result.count-1]:='';
         SetLength(Result.FileIsShort,Result.Count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileIsShort[Result.count-1]:=true
         else Result.FileIsShort[Result.count-1]:=false;
         SetLength(Result.FileShortStr,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileShortStr[Result.count-1]:=
         genfs_fat_extract_short_name(Pfat_directory_structure(@detectcontent)^)
         else Result.FileShortStr[Result.count-1]:='';
         SetLength(Result.FileOffset,Result.count);
         Result.FileOffset[Result.count-1]:=offset;
         SetLength(Result.FileClass,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileClass[Result.count-1]:=
         fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
         else
         Result.FileClass[Result.count-1]:=0;
         SetLength(Result.FileDirSize,Result.count);
         Result.FileDirSize[Result.count-1]:=sizeof(fat_directory_structure);
         if(Result.FileClass[Result.count-1]=fat_directory_directory)
         and(UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.') and (subdir) then
          begin
           temppath:=genfs_search_for_path(fs,basedir+tempstr,
           (Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16+
           Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
           fs.fat16.header.head.bpb_SectorPerCluster*fs.fat16.header.head.bpb_bytesPerSector);
           for i:=1 to temppath.Count do
            begin
             inc(Result.Count);
             SetLength(Result.FilePath,Result.count);
             SetLength(Result.FileOffset,Result.count);
             SetLength(Result.FileClass,Result.count);
             SetLength(Result.FileDirSize,Result.count);
             SetLength(Result.FileShortStr,Result.Count);
             SetLength(Result.FileIsShort,Result.count);
             Result.FilePath[Result.count-1]:=temppath.FilePath[i-1];
             Result.FileOffset[Result.count-1]:=temppath.FileOffset[i-1];
             Result.FileClass[Result.count-1]:=temppath.FileClass[i-1];
             Result.FileDirSize[Result.count-1]:=temppath.FileDirSize[i-1];
             Result.FileShortStr[Result.Count-1]:=temppath.FileShortStr[i-1];
             Result.FileIsShort[Result.count-1]:=true;
            end;
          end;
        end;
       inc(offset,sizeof(fat_directory_structure));
       tempnum:=offset div (fs.fat16.header.head.bpb_bytesPerSector*
       fs.fat16.header.head.bpb_SectorPerCluster)+2;
       tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat16.header.head.bpb_bytesPerSector*
       fs.fat16.header.head.bpb_SectorPerCluster)+2;
       if(tempnum>tempnum2) then
        begin
         ii1:=tempnum2 shr 1; ii2:=tempnum mod 2;
         if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_using) then break
         else offset:=((fs.fat16.entrypair+ii1)^.entry16[ii2+1]-2)
         *fs.fat16.header.head.bpb_bytesPerSector*fs.fat16.header.head.bpb_SectorPerCluster;
        end;
      end;
    end
   else
    begin
     if(startoffset=0) then
      begin
       offset:=0; index:=1;
       pathstr:=genfs_path_to_path_string(basedir); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
       while(index<=pathstr.count)do
        begin
         genfs_io_read(fs,detectcontent,fs.fat16.datastart+offset,sizeof(fat_directory_structure));
         if(detectcontent[1]=$00) and (bool=false) then
          begin
           if(fatstr.unicodefn<>nil) then
            begin
             FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
            end;
           break;
          end
         else
          begin
           fat_MoveDirStructStringToFatString(Pfat_directory_structure(@detectcontent)^,fatstr);
           tempstr:=fat_FatStringToPWideChar(fatstr);
           if(UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.')
           and(fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
           =fat_directory_directory) and (tempstr=pathstr.path[index-1]) then
            begin
             offset:=(Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16
             +Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
             fs.fat16.header.head.bpb_SectorPerCluster*fs.fat16.header.head.bpb_bytesPerSector;
             inc(index);
             if(fatstr.unicodefncount>0) then
              begin
               FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
              end;
             FreeMem(tempstr);
             continue;
            end;
           if(fatstr.unicodefncount>0) then
            begin
             FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
            end;
           FreeMem(tempstr);
          end;
         inc(offset,sizeof(fat_directory_structure));
         tempnum:=offset div (fs.fat16.header.head.bpb_bytesPerSector*
         fs.fat16.header.head.bpb_SectorPerCluster)+2;
         tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat16.header.head.bpb_bytesPerSector*
         fs.fat16.header.head.bpb_SectorPerCluster)+2;
         if(tempnum>tempnum2) then
          begin
           if(tempnum>tempnum2) then
            begin
             ii1:=tempnum2 shr 1; ii2:=tempnum mod 2;
             if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_using) then break
             else offset:=((fs.fat16.entrypair+ii1)^.entry16[ii2+1]-2)
             *fs.fat16.header.head.bpb_bytesPerSector*fs.fat16.header.head.bpb_SectorPerCluster;
            end;
          end;
        end;
      end
     else offset:=startoffset;
     fatstr.unicodefn:=nil; fatstr.unicodefncount:=0; bool:=false;
     while(True)do
      begin
       tempnum:=offset div (fs.fat16.header.head.bpb_bytesPerSector*
       fs.fat16.header.head.bpb_SectorPerCluster)+2;
       ii1:=tempnum shr 1; ii2:=tempnum mod 2;
       if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])=fat_available) then break;
       genfs_io_read(fs,detectcontent,fs.fat16.datastart+offset,sizeof(fat_directory_structure));
       if(detectcontent[1]=$00) then
        begin
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         break;
        end
       else
        begin
         inc(Result.Count);
         SetLength(Result.FileFree,Result.count);
         Result.FileFree[Result.count-1]:=detectcontent[1]=$E5;
         SetLength(Result.FilePath,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FilePath[Result.count-1]:=basedir+'/'+tempstr
         else Result.FilePath[Result.count-1]:='';
         SetLength(Result.FileIsShort,Result.Count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileIsShort[Result.count-1]:=true
         else Result.FileIsShort[Result.count-1]:=false;
         SetLength(Result.FileShortStr,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileShortStr[Result.count-1]:=
         genfs_fat_extract_short_name(Pfat_directory_structure(@detectcontent)^)
         else Result.FileShortStr[Result.count-1]:='';
         SetLength(Result.FileOffset,Result.count);
         Result.FileOffset[Result.count-1]:=offset;
         SetLength(Result.FileClass,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileClass[Result.count-1]:=
         fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
         else
         Result.FileClass[Result.count-1]:=0;
         SetLength(Result.FileDirSize,Result.count);
         Result.FileDirSize[Result.count-1]:=sizeof(fat_directory_structure);
         if(Result.FileClass[Result.count-1]=fat_directory_directory)
         and (Pfat_directory_structure(@detectcontent)^.directoryfilesize=0)
         and (UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.') and (subdir) then
          begin
           temppath:=genfs_search_for_path(fs,basedir+'/'+tempstr,
           (Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16+
           Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
           fs.fat16.header.head.bpb_SectorPerCluster*fs.fat16.header.head.bpb_bytesPerSector);
           for i:=1 to temppath.Count do
            begin
             inc(Result.Count);
             SetLength(Result.FilePath,Result.count);
             SetLength(Result.FileOffset,Result.count);
             SetLength(Result.FileClass,Result.count);
             SetLength(Result.FileDirSize,Result.count);
             SetLength(Result.FileShortStr,Result.Count);
             SetLength(Result.FileIsShort,Result.count);
             Result.FilePath[Result.count-1]:=temppath.FilePath[i-1];
             Result.FileOffset[Result.count-1]:=temppath.FileOffset[i-1];
             Result.FileClass[Result.count-1]:=temppath.FileClass[i-1];
             Result.FileDirSize[Result.count-1]:=temppath.FileDirSize[i-1];
             Result.FileShortStr[Result.Count-1]:=temppath.FileShortStr[i-1];
             Result.FileIsShort[Result.count-1]:=true;
            end;
          end;
        end;
       inc(offset,sizeof(fat_directory_structure));
       tempnum:=offset div (fs.fat16.header.head.bpb_bytesPerSector*
       fs.fat16.header.head.bpb_SectorPerCluster)+2;
       tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat16.header.head.bpb_bytesPerSector*
       fs.fat16.header.head.bpb_SectorPerCluster)+2;
       if(tempnum>tempnum2) then
        begin
         ii1:=tempnum2 shr 1; ii2:=tempnum mod 2;
         if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_using) then break
         else offset:=((fs.fat16.entrypair+ii1)^.entry16[ii2+1]-2)
         *fs.fat16.header.head.bpb_bytesPerSector*fs.fat16.header.head.bpb_SectorPerCluster;
        end;
      end;
    end;
  end
 else if(fs.fsname=filesystem_fat32) then
  begin
   if(basedir='/') or (basedir='\') then
    begin
     offset:=(fs.fat32.header.exthead.bpb_rootcluster-2)*
     fs.fat32.header.head.bpb_bytesPerSector*fs.fat32.header.head.bpb_SectorPerCluster;
     offset2:=0; fatstr.unicodefn:=nil; fatstr.unicodefncount:=0; bool:=false;
     while(True)do
      begin
       genfs_io_read(fs,detectcontent,fs.fat32.datastart+offset,sizeof(fat_directory_structure));
       if(detectcontent[1]=$00) and (bool=false) then
        begin
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         break;
        end
       else if(detectcontent[12]=fat_attribute_long_name) and (detectcontent[1]<>$E5) then
        begin
         inc(fatstr.unicodefncount);
         ReallocMem(fatstr.unicodefn,sizeof(fat_long_directory_structure)*fatstr.unicodefncount);
         fat_MoveLongDirStructStringToFatString(Pfat_long_directory_structure(@detectcontent)^,
         fatstr,fatstr.unicodefncount);
         if(bool=false) then offset2:=offset;
         bool:=true;
        end
       else if(detectcontent[12]<>fat_attribute_long_name) then
        begin
         fat_MoveDirStructStringToFatString(Pfat_directory_structure(@detectcontent)^,fatstr);
         tempstr:=fat_FatStringToPWideChar(fatstr);
         inc(Result.Count);
         SetLength(Result.FileFree,Result.count);
         Result.FileFree[Result.count-1]:=detectcontent[1]=$E5;
         SetLength(Result.FilePath,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FilePath[Result.count-1]:=basedir+tempstr
         else Result.FilePath[Result.count-1]:='';
         SetLength(Result.FileIsShort,Result.Count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileIsShort[Result.count-1]:=fatstr.unicodefncount=0
         else Result.FileIsShort[Result.count-1]:=false;
         SetLength(Result.FileShortStr,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileShortStr[Result.count-1]:=
         genfs_fat_extract_short_name(Pfat_directory_structure(@detectcontent)^)
         else Result.FileShortStr[Result.count-1]:='';
         SetLength(Result.FileOffset,Result.count);
         Result.FileOffset[Result.count-1]:=offset;
         SetLength(Result.FileClass,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileClass[Result.count-1]:=
         fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
         else
         Result.FileClass[Result.count-1]:=0;
         SetLength(Result.FileDirSize,Result.count);
         if(bool=false) then
         Result.FileDirSize[Result.count-1]:=sizeof(fat_directory_structure)
         else
         Result.FileDirSize[Result.Count-1]:=offset-offset2+sizeof(fat_directory_structure);
         if(Result.FileClass[Result.count-1]=fat_directory_directory)
         and(UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.') and (subdir) then
          begin
           temppath:=genfs_search_for_path(fs,basedir+tempstr,
           (Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16+
           Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
           fs.fat32.header.head.bpb_SectorPerCluster*fs.fat32.header.head.bpb_bytesPerSector);
           for i:=1 to temppath.Count do
            begin
             inc(Result.Count);
             SetLength(Result.FilePath,Result.count);
             SetLength(Result.FileOffset,Result.count);
             SetLength(Result.FileClass,Result.count);
             SetLength(Result.FileDirSize,Result.count);
             SetLength(Result.FileShortStr,Result.Count);
             SetLength(Result.FileIsShort,Result.count);
             Result.FilePath[Result.count-1]:=temppath.FilePath[i-1];
             Result.FileOffset[Result.count-1]:=temppath.FileOffset[i-1];
             Result.FileClass[Result.count-1]:=temppath.FileClass[i-1];
             Result.FileDirSize[Result.count-1]:=temppath.FileDirSize[i-1];
             Result.FileShortStr[Result.Count-1]:=temppath.FileShortStr[i-1];
             Result.FileIsShort[Result.count-1]:=temppath.FileIsShort[i-1];
            end;
          end;
         FreeMem(tempstr);
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         bool:=false;
        end;
       inc(offset,sizeof(fat_directory_structure));
       tempnum:=offset div (fs.fat32.header.head.bpb_bytesPerSector*
       fs.fat32.header.head.bpb_SectorPerCluster)+2;
       tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat32.header.head.bpb_bytesPerSector*
       fs.fat32.header.head.bpb_SectorPerCluster)+2;
       if(tempnum>tempnum2) then
        begin
         ii1:=tempnum2 shr 1; ii2:=tempnum mod 2;
         if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_using) then break
         else offset:=((fs.fat32.entrypair+ii1)^.entry32[ii2+1]-2)
         *fs.fat32.header.head.bpb_bytesPerSector*fs.fat32.header.head.bpb_SectorPerCluster;
        end;
      end;
    end
   else
    begin
     if(startoffset=fs.fat32.header.head.bpb_bytesPerSector*
     fs.fat32.header.head.bpb_SectorPerCluster*(fs.fat32.header.exthead.bpb_rootcluster-2))
     or (startoffset=0) then
      begin
       offset:=fs.fat32.header.head.bpb_bytesPerSector*
       fs.fat32.header.head.bpb_SectorPerCluster*(fs.fat32.header.exthead.bpb_rootcluster-2); index:=1;
       pathstr:=genfs_path_to_path_string(basedir);
       fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
       while(index<=pathstr.count)do
        begin
         genfs_io_read(fs,detectcontent,fs.fat32.datastart+offset,sizeof(fat_directory_structure));
         if(detectcontent[1]=$00) and (bool=false) then
          begin
           if(fatstr.unicodefn<>nil) then
            begin
             FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
            end;
           break;
          end
         else if(detectcontent[12]=fat_attribute_long_name) and (detectcontent[1]<>$E5) then
          begin
           inc(fatstr.unicodefncount);
           ReallocMem(fatstr.unicodefn,sizeof(fat_long_directory_structure)*fatstr.unicodefncount);
           fat_MoveLongDirStructStringToFatString(Pfat_long_directory_structure(@detectcontent)^,
           fatstr,fatstr.unicodefncount);
           if(bool=false) then offset2:=offset;
           bool:=true;
          end
         else if(detectcontent[12]<>fat_attribute_long_name) then
          begin
           fat_MoveDirStructStringToFatString(Pfat_directory_structure(@detectcontent)^,fatstr);
           tempstr:=fat_FatStringToPWideChar(fatstr);
           if(fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)=
           fat_directory_directory)
           and (UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.') then
            begin
             offset:=(Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16
             +Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
             fs.fat32.header.head.bpb_SectorPerCluster*fs.fat32.header.head.bpb_bytesPerSector;
             inc(index);
             if(fatstr.unicodefncount>0) then
              begin
               FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
              end;
             FreeMem(tempstr);
             continue;
            end;
           if(fatstr.unicodefncount>0) then
            begin
             FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
            end;
           FreeMem(tempstr);
          end;
         inc(offset,sizeof(fat_directory_structure));
         tempnum:=offset div (fs.fat32.header.head.bpb_bytesPerSector*
         fs.fat32.header.head.bpb_SectorPerCluster)+2;
         tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat32.header.head.bpb_bytesPerSector*
         fs.fat32.header.head.bpb_SectorPerCluster)+2;
         if(tempnum>tempnum2) then
          begin
           ii1:=tempnum2 shr 1; ii2:=tempnum mod 2;
           if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_using) then break
           else offset:=((fs.fat32.entrypair+ii1)^.entry32[ii2+1]-2)
           *fs.fat32.header.head.bpb_bytesPerSector*fs.fat32.header.head.bpb_SectorPerCluster;
          end;
        end;
      end
     else offset:=startoffset;
     offset2:=0; fatstr.unicodefn:=nil; fatstr.unicodefncount:=0; bool:=false;
     while(True)do
      begin
       genfs_io_read(fs,detectcontent,fs.fat32.datastart+offset,sizeof(fat_directory_structure));
       if(detectcontent[1]=$00) and (bool=false) then
        begin
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         break;
        end
       else if(detectcontent[12]=fat_attribute_long_name) and (detectcontent[1]<>$E5) then
        begin
         inc(fatstr.unicodefncount);
         ReallocMem(fatstr.unicodefn,sizeof(fat_long_directory_structure)*fatstr.unicodefncount);
         fat_MoveLongDirStructStringToFatString(Pfat_long_directory_structure(@detectcontent)^,
         fatstr,fatstr.unicodefncount);
         if(bool=false) then offset2:=offset;
         bool:=true;
        end
       else if(detectcontent[12]<>fat_attribute_long_name) then
        begin
         fat_MoveDirStructStringToFatString(Pfat_directory_structure(@detectcontent)^,fatstr);
         tempstr:=fat_FatStringToPWideChar(fatstr);
         inc(Result.Count);
         SetLength(Result.FileFree,Result.count);
         Result.FileFree[Result.count-1]:=detectcontent[1]=$E5;
         SetLength(Result.FilePath,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FilePath[Result.count-1]:=basedir+'/'+tempstr
         else Result.FilePath[Result.count-1]:='';
         SetLength(Result.FileIsShort,Result.Count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileIsShort[Result.count-1]:=fatstr.unicodefncount=0
         else Result.FileIsShort[Result.count-1]:=false;
         SetLength(Result.FileShortStr,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileShortStr[Result.count-1]:=
         genfs_fat_extract_short_name(Pfat_directory_structure(@detectcontent)^)
         else Result.FileShortStr[Result.count-1]:='';
         SetLength(Result.FileOffset,Result.count);
         Result.FileOffset[Result.count-1]:=offset;
         SetLength(Result.FileClass,Result.count);
         if(Result.FileFree[Result.count-1]=false) then
         Result.FileClass[Result.count-1]:=
         fat_is_file(Pfat_directory_structure(@detectcontent)^.directoryattribute)
         else
         Result.FileClass[Result.count-1]:=0;
         SetLength(Result.FileDirSize,Result.count);
         if(bool=false) then
         Result.FileDirSize[Result.count-1]:=sizeof(fat_directory_structure)
         else
         Result.FileDirSize[Result.Count-1]:=offset-offset2+sizeof(fat_directory_structure);
         if(Result.FileClass[Result.count-1]=fat_directory_directory)
         and (Pfat_directory_structure(@detectcontent)^.directoryfilesize=0)
         and (UnicodeString(tempstr)<>'..') and (UnicodeString(tempstr)<>'.') and (subdir) then
          begin
           temppath:=genfs_search_for_path(fs,basedir+'/'+tempstr,
           (Pfat_directory_structure(@detectcontent)^.directoryfirstclusterhighword shl 16+
           Pfat_directory_structure(@detectcontent)^.directoryfirstclusterlowword-2)*
           fs.fat32.header.head.bpb_SectorPerCluster*fs.fat32.header.head.bpb_bytesPerSector);
           for i:=1 to temppath.Count do
            begin
             inc(Result.Count);
             SetLength(Result.FilePath,Result.count);
             SetLength(Result.FileOffset,Result.count);
             SetLength(Result.FileClass,Result.count);
             SetLength(Result.FileDirSize,Result.count);
             SetLength(Result.FileShortStr,Result.Count);
             SetLength(Result.FileIsShort,Result.count);
             Result.FilePath[Result.count-1]:=temppath.FilePath[i-1];
             Result.FileOffset[Result.count-1]:=temppath.FileOffset[i-1];
             Result.FileClass[Result.count-1]:=temppath.FileClass[i-1];
             Result.FileDirSize[Result.count-1]:=temppath.FileDirSize[i-1];
             Result.FileShortStr[Result.Count-1]:=temppath.FileShortStr[i-1];
             Result.FileIsShort[Result.count-1]:=temppath.FileIsShort[i-1];
            end;
          end;
         FreeMem(tempstr);
         if(fatstr.unicodefn<>nil) then
          begin
           FreeMem(fatstr.unicodefn); fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
          end;
         bool:=false;
        end;
       inc(offset,sizeof(fat_directory_structure));
       tempnum:=offset div (fs.fat32.header.head.bpb_bytesPerSector*
       fs.fat32.header.head.bpb_SectorPerCluster)+2;
       tempnum2:=(offset-sizeof(fat_directory_structure)) div (fs.fat32.header.head.bpb_bytesPerSector*
       fs.fat32.header.head.bpb_SectorPerCluster)+2;
       if(tempnum>tempnum2) then
        begin
         ii1:=tempnum2 shr 1; ii2:=tempnum mod 2;
         if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_using) then break
         else offset:=((fs.fat32.entrypair+ii1)^.entry32[ii2+1]-2)
         *fs.fat32.header.head.bpb_bytesPerSector*fs.fat32.header.head.bpb_SectorPerCluster;
        end;
      end;
    end;
  end
 else
  begin

  end;
end;
{FAT File System next number of clusters}
function genfs_filesystem_get_next_cluster(fs:genfs_filesystem;startcluster:SizeUint;count:SizeUint):genfs_index_list;
var i,ii1,ii2,index:SizeUint;
begin
 index:=0; Result.count:=count; SetLength(Result.index,count);
 if(fs.fsname=filesystem_fat12) then
  begin
   i:=startcluster;
   while(i<=fs.fat12.entrycount shl 1)do
    begin
     ii1:=i shr 1; ii2:=i mod 2;
     if(index>=count) then break;
     if(ii2=0) then
      begin
       if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)=fat_available) then
        begin
         inc(index); Result.index[index-1]:=i;
        end;
      end
     else if(ii2=1) then
      begin
       if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)=fat_available) then
        begin
         inc(index); Result.index[index-1]:=i;
        end;
      end;
     inc(i);
    end;
  end
 else if(fs.fsname=filesystem_fat16) then
  begin
   i:=startcluster;
   while(i<=fs.fat16.entrycount shl 1)do
    begin
     ii1:=i shr 1; ii2:=i mod 2;
     if(index>=count) then break;
     if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])=fat_available) then
      begin
       inc(index); Result.index[index-1]:=i;
      end;
     inc(i);
    end;
  end
 else if(fs.fsname=filesystem_fat32) then
  begin
   i:=startcluster;
   while(i<=fs.fat32.entrycount shl 1)do
    begin
     ii1:=i shr 1; ii2:=i mod 2;
     if(index>=count) then break;
     if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])=fat_available) then
      begin
       inc(index); Result.index[index-1]:=i;
      end;
     inc(i);
    end;
  end;
end;
{Get What Cluster is using by this directory}
function genfs_filesystem_get_using_cluster(fs:genfs_filesystem;startcluster:SizeUint):genfs_index_list;
var i,ii1,ii2,index:SizeUint;
begin
 Result.count:=0; SetLength(Result.index,1);
 if(fs.fsname=filesystem_fat12) then
  begin
   i:=startcluster;
   while(i<=fs.fat12.entrycount shl 1)do
    begin
     ii1:=i shr 1; ii2:=i mod 2;
     if(ii2=0) then
      begin
       if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_end)
       and (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_cluster_broken) then
        begin
         inc(Result.count);
         SetLength(Result.index,Result.count);
         Result.index[Result.count-1]:=i;
         if(i<>(fs.fat12.entrypair+ii1)^.entry12.entry1) then
         i:=(fs.fat12.entrypair+ii1)^.entry12.entry1
         else break;
        end
       else if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)=fat_end) then
        begin
         inc(Result.count);
         SetLength(Result.index,Result.count);
         Result.index[Result.count-1]:=i; break;
        end
       else break;
      end
     else if(ii2=1) then
      begin
       if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)<>fat_end)
       and (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)<>fat_cluster_broken) then
        begin
         inc(Result.count);
         SetLength(Result.index,Result.count);
         Result.index[Result.count-1]:=i;
         if(i<>(fs.fat12.entrypair+ii1)^.entry12.entry2) then
         i:=(fs.fat12.entrypair+ii1)^.entry12.entry2
         else break;
        end
       else if(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)=fat_end) then
        begin
         inc(Result.count);
         SetLength(Result.index,Result.count);
         Result.index[Result.count-1]:=i; break;
        end
       else break;
      end;
    end;
  end
 else if(fs.fsname=filesystem_fat16) then
  begin
   i:=startcluster;
   while(i<=fs.fat16.entrycount shl 1)do
    begin
     ii1:=i shr 1; ii2:=i mod 2;
     if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_end)
     and (fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_cluster_broken) then
      begin
       inc(Result.count);
       SetLength(Result.index,Result.count);
       Result.index[Result.count-1]:=i;
       if(i<>(fs.fat16.entrypair+ii1)^.entry16[ii2+1]) then
       i:=(fs.fat16.entrypair+ii1)^.entry16[ii2+1]
       else break;
      end
     else if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_end) then
      begin
       inc(Result.count);
       SetLength(Result.index,Result.count);
       Result.index[Result.count-1]:=i; break;
      end
     else break;
    end;
  end
 else if(fs.fsname=filesystem_fat32) then
  begin
   i:=startcluster;
   while(i<=fs.fat32.entrycount shl 1)do
    begin
     ii1:=i shr 1; ii2:=i mod 2;
     if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_end)
     and(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_cluster_broken) then
      begin
       inc(Result.count);
       SetLength(Result.index,Result.count);
       Result.index[Result.count-1]:=i;
       if(i<>(fs.fat32.entrypair+ii1)^.entry32[ii2+1]) then
       i:=(fs.fat32.entrypair+ii1)^.entry32[ii2+1]
       else break;
      end
     else if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])=fat_end) then
      begin
       inc(Result.count);
       SetLength(Result.index,Result.count);
       Result.index[Result.count-1]:=i; break;
      end
     else break;
    end;
  end;
end;
{Extract the File Name from File Path}
function genfs_extract_filename(const str:UnicodeString):UnicodeString;
var i:SizeUint;
begin
 i:=length(str);
 while(i>0)do
  begin
   if(str[i]='/') or (str[i]='\') then break;
   dec(i);
  end;
 Result:=Copy(str,i+1,length(str)-i);
end;
{Extract the File Path from File Path}
function genfs_extract_filepath(const str:UnicodeString):UnicodeString;
var i:SizeUint;
begin
 i:=length(str);
 while(i>0)do
  begin
   if(str[i]='/') or (str[i]='\') then break;
   dec(i);
  end;
 Result:=Copy(str,1,i-1);
end;
{FAT File System edit item name}
procedure genfs_filesystem_reset_name(var fs:genfs_filesystem;basedir:UnicodeString);
var i,j,k,len:SizeUint;
    inlist:genfs_inner_path;
    filename:UnicodeString;
    tempstr,tempstr2:PWideChar;
begin
 if(fs.fsname<>filesystem_fat12) and (fs.fsname<>filesystem_fat16)
 and (fs.fsname<>filesystem_fat32) then exit;
 i:=1;
 inlist:=genfs_search_for_path(fs,basedir);
 while(i<=inlist.Count)do
  begin
   j:=1;
   while(j<=inlist.count)do
    begin
     if(i=j) then
      begin
       inc(j); continue;
      end;
     if(inlist.FilePath[i-1]='') or (inlist.FilePath[j-1]='') then
      begin
       inc(j); continue;
      end;
     if(genfs_check_same_path(inlist.FilePath[i-1],inlist.FilePath[j-1])=false) then
      begin
       inc(j); continue;
      end;
     if(inlist.FileShortStr[i-1]=inlist.FileShortStr[j-1]) then
      begin
       len:=length(inlist.FileShortStr[i-1]);
       if(len>=8) and (inlist.FileShortStr[i-1][8]>='9') then
        begin
         filename:=inlist.FilePath[i-1];
         tempstr:=UnicodeStringToPWideChar(filename);
         tempstr2:=fat_get_latter_four_random_char(tempstr);
         inlist.FileShortStr[i-1]:=
         Copy(inlist.FileShortStr[i-1],1,2)+UnicodeStringToString(tempstr2)
         +'~1.'+Copy(inlist.FileShortStr[i-1],10,3);
         for k:=1 to 8 do
          begin
           if(k>len) then break
           else
            begin
             if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat12.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-1,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat16.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-1,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat32.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-1,1);
            end;
          end;
         for k:=10 to 12 do
          begin
           if(k>len) then break
           else
            begin
             if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat12.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-2,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat16.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-2,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat32.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-2,1);
            end;
          end;
        end
       else if(len>=8) then
        begin
         inlist.FileShortStr[i-1][8]:=WideChar(Word(inlist.FileShortStr[i-1][8])+1);
         for k:=1 to 8 do
          begin
           if(k>len) then break
           else
            begin
             if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat12.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-1,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat16.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-1,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat32.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-1,1);
            end;
          end;
         for k:=10 to 12 do
          begin
           if(k>len) then break
           else
            begin
             if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat12.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-2,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat16.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-2,1)
             else if(fs.fsname=filesystem_fat12) then
             genfs_io_write(fs,Char(inlist.FileShortStr[i-1][k]),
             fs.fat32.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
             sizeof(fat_directory_structure)+k-2,1);
            end;
          end;
        end;
      end;
     inc(j);
    end;
   inc(i);
  end;
end;
{File System Path Combiner}
function genfs_filesystem_combine_path(path1,path2:UnicodeString):UnicodeString;
var len1,len2:SizeUint;
begin
 len1:=length(path1); len2:=length(path2);
 if(len1>=1) and ((path1[len1]='/') or (path1[len1]='\')) then Result:=path1+path2
 else if(len2>=1) and ((path2[1]='/') or (path2[1]='\')) then Result:=path1+path2
 else Result:=path1+'/'+path2;
end;
{File System Add item}
procedure genfs_filesystem_add(var fs:genfs_filesystem;srcpath:UnicodeString;indestpath:UnicodeString);
var extlist:genfs_path;
    inlist:genfs_inner_path;
    path:genfs_path_string;
    tempstr:PWideChar;
    fatstr:fat_string;
    fatdir:fat_directory;
    rootpath,tempdestpath,detectpath,temppath,temppath2:UnicodeString;
    offset:SizeUint;
    rootlen:SizeUint;
    bool:boolean;
    i,j,k,m,n,a,b,c,len:SizeUint;
    destpath:UnicodeString;
    {For FAT Only}
    tempPrevPos:SizeUint;
    tempStartPos:SizeUint;
    tempNextCluster:SizeUint;
    tempNextPos,tempNextPos2:SizeUint;
    tempNextOffset,tempNextOffset2:SizeUint;
    tempOffset:SizeUint;
    tempindex:SizeUint;
    tempHaveDot:boolean;
    templist:genfs_index_list;
    EraseDir:boolean;
    EraseCount:SizeUint;
    CompareCount:SizeUint;
    sdir:fat_directory_structure;
    {For File System Specific Only}
    tempnum1,tempnum2,tempnum3,tempnum4,tempnum5,ii1,ii2:SizeUint;
    copycontent:array[1..512] of byte;
begin
 len:=length(indestpath);
 if(len>1) and ((indestpath[len]='\') or (indestpath[len]='/')) then
  begin
   destpath:=Copy(indestpath,1,len-1);
  end
 else destpath:=indestpath;
 bool:=genfs_is_mask(srcpath);
 if(bool) then
  begin
   len:=length(srcpath); i:=len;
   while(i>0)do
    begin
     if(srcpath[i]='/') or (srcpath[i]='\') then break;
     dec(i);
    end;
   rootpath:=Copy(srcpath,1,i); rootlen:=i;
  end
 else
  begin
   len:=length(srcpath);
   if(FileExists(srcpath)) and ((destpath='\') or (destpath='/')) then
    begin
     rootpath:=genfs_extract_filepath(srcpath)+'/'; rootlen:=length(rootpath);
    end
   else if(FileExists(srcpath)) then
    begin
     rootpath:=srcpath; rootlen:=length(srcpath);
    end
   else if(srcpath[len]='/') or (srcpath[len]='\') then
    begin
     rootpath:=Copy(srcpath,1,len-1); rootlen:=length(srcpath)-1;
    end
   else
    begin
     rootpath:=genfs_extract_filepath(srcpath)+'/'; rootlen:=length(rootpath);
    end;
  end;
 extlist:=genfs_search_for_path_external(srcpath,bool);
 inlist:=genfs_search_for_path(fs,'/'); i:=1;
 if(fs.fsname=filesystem_fat12) or (fs.fsname=filesystem_fat16) or
 (fs.fsname=filesystem_fat32) then
  begin
   if(fs.fsname=filesystem_fat12) then
    begin
     tempnum1:=fs.fat12.header.head.bpb_bytesPerSector;
     tempnum2:=fs.fat12.header.head.bpb_SectorPerCluster;
    end
   else if(fs.fsname=filesystem_fat16) then
    begin
     tempnum1:=fs.fat16.header.head.bpb_bytesPerSector;
     tempnum2:=fs.fat16.header.head.bpb_SectorPerCluster;
    end
   else if(fs.fsname=filesystem_fat32) then
    begin
     tempnum1:=fs.fat32.header.head.bpb_bytesPerSector;
     tempnum2:=fs.fat32.header.head.bpb_SectorPerCluster;
    end;
   if(fs.fsname=filesystem_fat12) then
   tempprevpos:=2
   else if(fs.fsname=filesystem_fat16) then
   tempprevpos:=2
   else if(fs.fsname=filesystem_fat32) then
   tempprevpos:=fs.fat32.header.exthead.bpb_rootcluster;
   tempnextpos:=tempprevpos;
   tempnextoffset:=0;
   for i:=1 to extlist.count do
    begin
     temppath:=Copy(extlist.FilePath[i-1],rootlen+1,length(extlist.Filepath[i-1])-rootlen);
     detectpath:=genfs_filesystem_combine_path(destpath,temppath);
     path:=genfs_path_to_path_string(detectpath);
     temppath2:='/'; j:=1;
     while(j<=path.count) do
      begin
       if(temppath2='/') or (temppath2='\') then
       temppath2:=temppath2+path.path[j-1]
       else
       temppath2:=temppath2+'/'+path.path[j-1];
       k:=1;
       while(k<=inlist.Count)do
        begin
         if((temppath2=inlist.FilePath[k-1]) and (inlist.FileClass[k-1]<>fat_directory_volume)) then break;
         inc(k);
        end;
       if(k<=inlist.count) then
        begin
         if(fs.fsname=filesystem_fat12) then
         genfs_io_read(fs,sdir,fs.fat12.datastart+inlist.FileOffset[k-1],sizeof(fat_directory_structure))
         else if(fs.fsname=filesystem_fat16) then
         genfs_io_read(fs,sdir,fs.fat16.datastart+inlist.FileOffset[k-1],sizeof(fat_directory_structure))
         else if(fs.fsname=filesystem_fat32) then
         genfs_io_read(fs,sdir,fs.fat32.datastart+
         inlist.FileOffset[k-1]+inlist.FileDirSize[k-1]-sizeof(fat_directory_structure),
         sizeof(fat_directory_structure));
         tempprevpos:=tempnextpos;
         tempnextpos:=sdir.directoryfirstclusterhighword shl 16+
         sdir.directoryfirstclusterlowword;
         inc(j); continue;
        end;
       EraseDir:=false;
       tempstr:=UnicodeStringToPWideChar(path.path[j-1]);
       CompareCount:=fat_calculate_directory_size(tempstr) shr 5;
       FreeMem(tempstr);
       k:=1; b:=1; if(j>1) then temphavedot:=false else temphavedot:=true;
       while(k<=inlist.count) do
        begin
         if(genfs_check_prefix(temppath2,inlist.FilePath[k-1],true))then
          begin
           if(inlist.FileFree[k-1]) and (EraseDir=false) then
            begin
             EraseDir:=true; EraseCount:=1;
             tempNextPos2:=tempnextpos; tempNextOffset2:=tempnextoffset;
            end
           else if(inlist.FileFree[k-1]) and (EraseDir) then
            begin
             inc(EraseCount);
            end
           else if(inlist.FileFree[k-1]=false) then
            begin
             EraseDir:=false; EraseCount:=0;
             if(CompareCount<=EraseCount) then
              begin
               tempnextpos:=tempnextpos2; tempnextoffset:=tempnextoffset2;
               tempnextpos2:=0; tempnextoffset2:=0;
               break;
              end;
            end;
           temphavedot:=true;
           if((tempnextoffset+inlist.FileDirSize[k-1]) div (tempnum1*tempnum2)>=b) then
            begin
             inc(b);
             tempnextoffset:=0;
             m:=3;
             if(fs.fsname=filesystem_fat12) then
              begin
               while(m<=fs.fat12.entrycount shl 1) do
                begin
                 if(m=tempprevpos+1) then
                  begin
                   inc(m); continue;
                  end;
                 ii1:=m shr 1; ii2:=m mod 2;
                 if(ii2=1) and
                 (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_using) and
                 (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_cluster_broken)
                 then
                  begin
                   tempnextpos:=m-1; break;
                  end
                 else if(ii2=0) and
                 (fat12_check_cluster_status((fs.fat12.entrypair+ii1-1)^.entry12.entry2)<>fat_using) and
                 (fat12_check_cluster_status((fs.fat12.entrypair+ii1-1)^.entry12.entry2)<>fat_cluster_broken)
                 then
                  begin
                   tempnextpos:=m-1; break;
                  end;
                 inc(m);
                end;
              end
             else if(fs.fsname=filesystem_fat16) then
              begin
               while(m<=fs.fat16.entrycount shl 1) do
                begin
                 if(m=tempprevpos+1) then
                  begin
                   inc(m); continue;
                  end;
                 ii1:=(m-1) shr 1; ii2:=(m-1) mod 2;
                 if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_using)
                 and(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_cluster_broken)then
                  begin
                   tempnextpos:=m-1; break;
                  end;
                 inc(m);
                end;
              end
             else if(fs.fsname=filesystem_fat32) then
              begin
               while(m<=fs.fat32.entrycount shl 1) do
                begin
                 if(m=tempprevpos+1) then
                  begin
                   inc(m); continue;
                  end;
                 ii1:=(m-1) shr 1; ii2:=(m-1) mod 2;
                 if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_using)
                 and(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_cluster_broken)then
                  begin
                   tempnextpos:=m-1; break;
                  end;
                 inc(m);
                end;
              end;
            end
           else inc(tempnextoffset,inlist.FileDirSize[k-1]);
          end;
         inc(k);
        end;
       if(k=0) and (j>1) then
        begin
         m:=3;
         if(fs.fsname=filesystem_fat12) then
          begin
           while(m<=fs.fat12.entrycount shl 1) do
            begin
             if(m=tempprevpos+1) then
              begin
               inc(m); continue;
              end;
             ii1:=m shr 1; ii2:=m mod 2;
             if(ii2=1) and
             (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_using) and
             (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_cluster_broken)
              then
               begin
                tempnextpos:=m-1; break;
               end
              else if(ii2=0) and
              (fat12_check_cluster_status((fs.fat12.entrypair+ii1-1)^.entry12.entry2)<>fat_using) and
              (fat12_check_cluster_status((fs.fat12.entrypair+ii1-1)^.entry12.entry2)<>fat_cluster_broken)
               then
                begin
                 tempnextpos:=m-1; break;
                end;
               inc(m);
              end;
            end
           else if(fs.fsname=filesystem_fat16) then
            begin
             while(m<=fs.fat16.entrycount shl 1) do
              begin
               if(m=tempprevpos+1) then
                begin
                 inc(m); continue;
                end;
               ii1:=(m-1) shr 1; ii2:=(m-1) mod 2;
               if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_using)
               and(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_cluster_broken)then
                begin
                 tempnextpos:=m-1; break;
                end;
               inc(m);
              end;
            end
           else if(fs.fsname=filesystem_fat32) then
            begin
             while(m<=fs.fat32.entrycount shl 1) do
              begin
               if(m=tempprevpos+1) then
                begin
                 inc(m); continue;
                end;
               ii1:=(m-1) shr 1; ii2:=(m-1) mod 2;
               if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_using)
               and(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])<>fat_cluster_broken)then
                begin
                 tempnextpos:=m-1; break;
                end;
              inc(m);
             end;
           end;
        end;
       n:=3;
       if(fs.fsname=filesystem_fat12) then
        begin
         while(n<=fs.fat12.entrycount shl 1) do
          begin
           if(n=tempnextpos+1) or (n=tempprevpos+1) then
            begin
             inc(n); continue;
            end;
           ii1:=n shr 1; ii2:=n mod 2;
           if(ii2=1) and
           (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)=fat_available) then
             begin
              tempnextcluster:=n-1; break;
             end
            else if(ii2=0) and
            (fat12_check_cluster_status((fs.fat12.entrypair+ii1-1)^.entry12.entry2)=fat_available) then
             begin
              tempnextcluster:=n-1; break;
             end;
           inc(n);
          end;
        end
       else if(fs.fsname=filesystem_fat16) then
        begin
         while(n<=fs.fat16.entrycount shl 1) do
          begin
           if(n=tempnextpos+1) or (n=tempprevpos+1) then
            begin
             inc(n); continue;
            end;
           ii1:=(n-1) shr 1; ii2:=(n-1) mod 2;
           if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])=fat_available)then
            begin
             tempnextcluster:=n-1; break;
            end;
           inc(n);
          end;
        end
       else if(fs.fsname=filesystem_fat32) then
        begin
         while(n<=fs.fat32.entrycount shl 1) do
          begin
           if(n=tempnextpos+1) or (n=tempprevpos+1) then
            begin
             inc(n); continue;
            end;
           ii1:=(n-1) shr 1; ii2:=(n-1) mod 2;
           if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])=fat_available)then
            begin
             tempnextcluster:=n-1; break;
            end;
           inc(n);
          end;
        end;
       if(fs.fsname=filesystem_fat12) then
        begin
         if(temphavedot=false) and (j>1) then
          begin
           tempstr:=UnicodeStringToPWideChar('.');
           fatstr:=fat_PWideCharToFatString(tempstr);
           FreeMem(tempstr);
           fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
           genfs_date_to_fat_date,genfs_time_to_fat_time,0,
           tempnextpos);
           genfs_io_write(fs,fatdir.dir,
           fs.fat12.datastart+(tempnextpos-2)*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
           inc(tempnextoffset,sizeof(fat_directory_structure));
           tempstr:=UnicodeStringToPWideChar('..');
           fatstr:=fat_PWideCharToFatString(tempstr);
           FreeMem(tempstr);
           fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
           genfs_date_to_fat_date,genfs_time_to_fat_time,0,
           tempprevpos);
           genfs_io_write(fs,fatdir.dir,
           fs.fat12.datastart+(tempnextpos-2)*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
           inc(tempnextoffset,sizeof(fat_directory_structure));
          end;
         ii1:=tempnextpos shr 1; ii2:=tempnextpos mod 2;
         if(ii2=0) and
         (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)=fat_available) then
          begin
           (fs.fat12.entrypair+ii1)^.entry12.entry1:=fat12_final_cluster_low;
          end
         else if(ii2=1) and
         (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)=fat_available) then
           begin
            (fs.fat12.entrypair+ii1)^.entry12.entry2:=fat12_final_cluster_low;
           end;
         if(tempnextoffset=0) then
          begin
           ii1:=tempprevpos shr 1; ii2:=tempprevpos mod 2;
           if(ii2=0) and
           (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_using)
           and(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry1)<>fat_cluster_broken)
            then
             begin
              (fs.fat12.entrypair+ii1)^.entry12.entry1:=tempnextpos;
             end
           else if(ii2=1) and
           (fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)<>fat_using)
           and(fat12_check_cluster_status((fs.fat12.entrypair+ii1)^.entry12.entry2)<>fat_cluster_broken)
            then
             begin
              (fs.fat12.entrypair+ii1)^.entry12.entry2:=tempnextpos;
             end;
          end;
         tempstr:=UnicodeStringToPWideChar(path.path[j-1]);
         fatstr:=fat_PWideCharToFatString(tempstr);
         FreeMem(tempstr);
         if(j=path.count) and (extlist.IsFile[i-1]) then
         fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_file,
         genfs_date_to_fat_date,genfs_time_to_fat_time,
         genfs_external_file_size(extlist.FilePath[i-1]),
         tempnextcluster)
         else
         fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
         genfs_date_to_fat_date,genfs_time_to_fat_time,0,
         tempnextcluster);
         genfs_io_write(fs,fatdir.dir,
         fs.fat12.datastart+tempnextpos*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
         inc(tempnextoffset,sizeof(fat_directory_structure));
        end
       else if(fs.fsname=filesystem_fat16) then
        begin
         if(temphavedot=false) and (j>1) then
          begin
           ii1:=tempnextpos shr 1; ii2:=tempnextpos mod 2;
           (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=fat32_final_cluster_low;
           tempstr:=UnicodeStringToPWideChar('.');
           fatstr:=fat_PWideCharToFatString(tempstr);
           FreeMem(tempstr);
           fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
           genfs_date_to_fat_date,genfs_time_to_fat_time,0,
           tempnextpos);
           genfs_io_write(fs,fatdir.dir,
           fs.fat16.datastart+(tempnextpos-2)*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
           inc(tempnextoffset,sizeof(fat_directory_structure));
           tempstr:=UnicodeStringToPWideChar('..');
           fatstr:=fat_PWideCharToFatString(tempstr);
           FreeMem(tempstr);
           fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
           genfs_date_to_fat_date,genfs_time_to_fat_time,0,
           tempprevpos);
           genfs_io_write(fs,fatdir.dir,
           fs.fat16.datastart+(tempnextpos-2)*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
           inc(tempnextoffset,sizeof(fat_directory_structure));
          end;
         ii1:=tempnextpos shr 1; ii2:=tempnextpos mod 2;
         if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])=fat_available)then
          begin
           (fs.fat16.entrypair+ii1)^.entry16[ii2+1]:=fat16_final_cluster_low;
          end;
         if(tempnextoffset=0) then
          begin
           ii1:=tempprevpos shr 1; ii2:=tempprevpos mod 2;
           if(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_using)
           and(fat16_check_cluster_status((fs.fat16.entrypair+ii1)^.entry16[ii2+1])<>fat_cluster_broken) then
            begin
             (fs.fat16.entrypair+ii1)^.entry16[ii2+1]:=tempnextpos;
            end;
          end;
         tempstr:=UnicodeStringToPWideChar(path.path[j-1]);
         fatstr:=fat_PWideCharToFatString(tempstr);
         FreeMem(tempstr);
         if(j=path.count) and (extlist.IsFile[i-1]) then
         fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_file,
         genfs_date_to_fat_date,genfs_time_to_fat_time,
         genfs_external_file_size(extlist.FilePath[i-1]),
         tempnextcluster)
         else
         fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
         genfs_date_to_fat_date,genfs_time_to_fat_time,0,
         tempnextcluster);
         genfs_io_write(fs,fatdir.dir,
         fs.fat16.datastart+tempnextpos*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
         inc(tempnextoffset,sizeof(fat_directory_structure));
        end
       else if(fs.fsname=filesystem_fat32) then
        begin
         if(temphavedot=false) and (j>1) then
          begin
           tempstr:=UnicodeStringToPWideChar('.');
           fatstr:=fat_PWideCharToFatString(tempstr);
           FreeMem(tempstr);
           fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
           genfs_date_to_fat_date,genfs_time_to_fat_time,0,tempnextpos);
           genfs_io_write(fs,fatdir.dir,
           fs.fat32.datastart+(tempnextpos-2)*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
           inc(tempnextoffset,sizeof(fat_directory_structure));
           tempstr:=UnicodeStringToPWideChar('..');
           fatstr:=fat_PWideCharToFatString(tempstr);
           FreeMem(tempstr);
           fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
           genfs_date_to_fat_date,genfs_time_to_fat_time,0,
           tempprevpos);
           genfs_io_write(fs,fatdir.dir,
           fs.fat32.datastart+(tempnextpos-2)*tempnum1*tempnum2+tempnextoffset,sizeof(fat_directory_structure));
           inc(tempnextoffset,sizeof(fat_directory_structure));
          end;
         tempstr:=UnicodeStringToPWideChar(path.path[j-1]);
         fatstr:=fat_PWideCharToFatString(tempstr);
         FreeMem(tempstr);
         if(j=path.count) and (extlist.IsFile[i-1]) then
         fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_file,
         genfs_date_to_fat_date,genfs_time_to_fat_time,
         genfs_external_file_size(extlist.FilePath[i-1]),
         tempnextcluster)
         else
         fatdir:=fat_FatStringToFatDirectory(fatstr,fat_directory_directory,
         genfs_date_to_fat_date,genfs_time_to_fat_time,0,
         tempnextcluster);
         if(tempnextoffset+(fatstr.unicodefncount+1)*
         sizeof(fat_long_directory_structure)>tempnum1*tempnum2) then
          begin
           tempnum4:=(tempnextoffset+(fatstr.unicodefncount+1)*
           sizeof(fat_long_directory_structure)
           -tempnum1*tempnum2) div (tempnum1*tempnum2);
           templist:=genfs_filesystem_get_next_cluster(fs,2,tempnum4+1);
           ii1:=tempnextpos shr 1; ii2:=tempnextpos mod 2;
           (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=templist.index[0];
           for a:=1 to templist.count-1 do
            begin
             ii1:=templist.index[a-1] shr 1; ii2:=templist.index[a-1] mod 2;
             if(a=templist.count-1) then
              begin
               (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=fat32_final_cluster_low;
              end
             else
              begin
               (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=templist.index[a];
              end;
            end;
           tempnextcluster:=templist.index[templist.count-1];
          end
         else
          begin
           ii1:=tempnextpos shr 1; ii2:=tempnextpos mod 2;
           (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=fat32_final_cluster_low;
          end;
         c:=2;
         tempindex:=tempnextpos;
         tempoffset:=tempnextoffset;
         for a:=1 to (fatdir.longdircount+1) do
          begin
           if(tempoffset<tempnum1*tempnum2) then
            begin
             if(a<>fatdir.longdircount+1) then
              begin
               genfs_io_write(fs,(fatdir.longdir+a-1)^,
               fs.fat32.datastart+(tempindex-2)*tempnum1*tempnum2+tempoffset,sizeof(fat_directory_structure));
               inc(tempoffset,sizeof(fat_long_directory_structure));
              end
             else
              begin
               genfs_io_write(fs,fatdir.dir,
               fs.fat32.datastart+(tempindex-2)*tempnum1*tempnum2+tempoffset,sizeof(fat_directory_structure));
               inc(tempoffset,sizeof(fat_directory_structure));
              end;
            end
           else if(tempoffset>=tempnum1*tempnum2) then
            begin
             tempindex:=templist.index[c-1];
             tempoffset:=0;
             if(a<>fatdir.longdircount+1) then
              begin
               genfs_io_write(fs,(fatdir.longdir+a-1)^,
               fs.fat32.datastart+(tempindex-2)*tempnum1*tempnum2+tempoffset,sizeof(fat_directory_structure));
               inc(tempoffset,sizeof(fat_long_directory_structure));
              end
             else
              begin
               genfs_io_write(fs,fatdir.dir,
               fs.fat32.datastart+(tempindex-2)*tempnum1*tempnum2+tempoffset,sizeof(fat_directory_structure));
               inc(tempoffset,sizeof(fat_directory_structure));
              end;
             inc(c);
            end;
          end;
         tempnextoffset:=tempoffset;
         tempnextpos:=tempnextcluster;
         if(fatstr.unicodefn<>nil) then FreeMem(fatstr.unicodefn);
         fatstr.unicodefn:=nil; fatstr.unicodefncount:=0;
        end;
       inc(j);
       tempprevpos:=tempnextpos;
       tempnextpos:=tempnextcluster;
      end;
     {Move the content of File In It}
     if(extlist.IsFile[i-1]=true) then
      begin
       tempnum5:=genfs_external_file_size(extlist.FilePath[i-1]);
       tempnum4:=genfs_external_file_size(extlist.FilePath[i-1]) div (tempnum1*tempnum2);
       templist:=genfs_filesystem_get_next_cluster(fs,2,tempnum4+1);
       tempindex:=templist.index[0]; tempoffset:=0; a:=1;
       for c:=1 to templist.count-1 do
        begin
         ii1:=templist.index[c-1] shr 1; ii2:=templist.index[c-1] mod 2;
         if(fs.fsname=filesystem_fat12) and (c=templist.count-1) then
          begin
           if(ii2=0) then
            begin
             (fs.fat12.entrypair+ii1)^.entry12.entry1:=fat12_final_cluster_low;
            end
           else if(ii2=1) then
            begin
             (fs.fat12.entrypair+ii1)^.entry12.entry2:=fat12_final_cluster_low;
            end;
          end
         else if(fs.fsname=filesystem_fat12) then
          begin
           if(ii2=0) then
            begin
             (fs.fat12.entrypair+ii1)^.entry12.entry1:=templist.index[c];
            end
           else if(ii2=1) then
            begin
             (fs.fat12.entrypair+ii1)^.entry12.entry2:=templist.index[c];
            end;
          end
         else if(fs.fsname=filesystem_fat16) and (c=templist.count-1) then
          begin
           (fs.fat16.entrypair+ii1)^.entry16[ii2+1]:=fat16_final_cluster_low;
          end
         else if(fs.fsname=filesystem_fat16) then
          begin
           (fs.fat16.entrypair+ii1)^.entry16[ii2+1]:=templist.index[c];
          end
         else if(fs.fsname=filesystem_fat32) and (c=templist.count-1) then
          begin
           (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=fat32_final_cluster_low;
          end
         else if(fs.fsname=filesystem_fat32) then
          begin
           (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=templist.index[c];
          end;
        end;
       for c:=1 to (tempnum4*tempnum1*tempnum2+511) div 512 do
        begin
         if(c shl 9<=tempnum5) then
          begin
           genfs_external_io_read(extlist.FilePath[i-1],copycontent,(c-1)*512,512);
           if(fs.fsname=filesystem_fat12) then
           genfs_io_write(fs,copycontent,fs.fat12.datastart+
           (tempindex-2)*tempnum1*tempnum2+tempoffset,512)
           else if(fs.fsname=filesystem_fat16) then
           genfs_io_write(fs,copycontent,fs.fat16.datastart+
           (tempindex-2)*tempnum1*tempnum2+tempoffset,512)
           else if(fs.fsname=filesystem_fat32) then
           genfs_io_write(fs,copycontent,fs.fat32.datastart+
           (tempindex-2)*tempnum1*tempnum2+tempoffset,512);
          end
         else
          begin
           genfs_external_io_read(extlist.FilePath[i-1],copycontent,(c-1)*512,
           c shl 9-tempnum5);
           if(fs.fsname=filesystem_fat12) then
           genfs_io_write(fs,copycontent,fs.fat12.datastart+
           (tempindex-2)*tempnum1*tempnum2+tempoffset,
           c shl 9-tempnum5)
           else if(fs.fsname=filesystem_fat16) then
           genfs_io_write(fs,copycontent,fs.fat16.datastart+
           (tempindex-2)*tempnum1*tempnum2+tempoffset,
           c shl 9-tempnum5)
           else if(fs.fsname=filesystem_fat32) then
           genfs_io_write(fs,copycontent,fs.fat32.datastart+
           (tempindex-2)*tempnum1*tempnum2+tempoffset,
           c shl 9-tempnum5);
          end;
         inc(tempoffset,512);
         if(tempoffset>=tempnum1*tempnum2) then
          begin
           inc(a);
           tempindex:=templist.index[a-1]; tempoffset:=0;
          end;
        end;
       tempnextcluster:=templist.index[templist.count-1];
      end;
    end;
   bool:=false;
   if(fs.fsname=filesystem_fat32) then
    begin
     i:=2; fs.fat32.fsinfo.freecount:=0;
     while(i<=fs.fat32.entrycount shl 1) do
      begin
       ii1:=i shr 1; ii2:=i mod 2;
       if(fat32_check_cluster_status((fs.fat32.entrypair+ii1)^.entry32[ii2+1])=fat_available) then
        begin
         if(bool=false) then
          begin
           fs.fat32.fsinfo.nextfree:=i; bool:=true;
          end;
         inc(fs.fat32.fsinfo.freecount);
        end;
       inc(i);
      end;
    end;
  end;
 genfs_filesystem_reset_name(fs,genfs_extract_filepath(destpath));
 genfs_write(fs);
end;
{File System Delete Item}
procedure genfs_filesystem_delete(var fs:genfs_filesystem;delpath:UnicodeString);
var inlist:genfs_inner_path;
    temppath:UnicodeString;
    tempindex:genfs_index_list;
    templeft,tempright:SizeUint;
    tempoffset:SizeUint;
    ismask:boolean;
    sdir:fat_directory_structure;
    clearcontent:array[1..512] of byte;
    copycontent:array[1..32] of byte;
    i,j,k,ii1,ii2,tempnum1,tempnum2:SizeUint;
begin
 for i:=1 to 512 do clearcontent[i]:=0;
 ismask:=genfs_is_mask(delpath);
 i:=length(delpath);
 while(delpath[i]<>'/') or (delpath[i]<>'\') do dec(i);
 temppath:=Copy(delpath,1,i-1);
 if(temppath='') then temppath:='/';
 inlist:=genfs_search_for_path(fs,temppath);
 if(fs.fsname=filesystem_fat12) then
  begin
   tempnum1:=fs.fat12.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat12.header.head.bpb_SectorPerCluster;
   i:=inlist.Count;
   while(i>0)do
    begin
     if(ismask) then
      begin
       if(genfs_mask_match(delpath,inlist.FilePath[i-1])) then
        begin
         genfs_io_read(fs,sdir,fs.fat12.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
         sizeof(fat_directory_structure),
         sizeof(fat_directory_structure));
         tempindex:=genfs_filesystem_get_using_cluster(fs,
         sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword);
         for j:=1 to tempindex.count do
          begin
           ii1:=tempindex.index[j-1] shr 1; ii2:=tempindex.index[j-1] mod 2;
           if(ii2=0) then
           (fs.fat12.entrypair+ii1)^.entry12.entry1:=0
           else if(ii2=1) then
           (fs.fat12.entrypair+ii1)^.entry12.entry2:=0;
           tempoffset:=(tempindex.index[j-1]-2)*tempnum1*tempnum2;
           k:=tempnum1*tempnum2 shr 9;
           while(k>0)do
            begin
             genfs_io_write(fs,clearcontent,fs.fat12.datastart+(k-1) shl 9,512);
             dec(k);
            end;
          end;
         j:=1;
         while(j<=inlist.count)do
          begin
           if(temppath=inlist.FilePath[j-1]) then break;
           inc(j);
          end;
         tempoffset:=inlist.FileOffset[j-1];
         genfs_io_read(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+inlist.FileDirSize[j-1]-
         sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         for j:=1 to sizeof(fat_directory_structure) do PByte(Pointer(@sdir)+j-1)^:=0;
         Pbyte(@sdir)^:=$E5;
         for j:=1 to inlist.FileDirSize[j-1] shr 5 do
         genfs_io_write(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+
         (j-1)*sizeof(fat_directory_structure),sizeof(fat_directory_structure));
        end;
      end
     else
      begin
       if(genfs_check_prefix(delpath,inlist.FilePath[i-1])) then
        begin
         genfs_io_read(fs,sdir,fs.fat12.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
         sizeof(fat_directory_structure),
         sizeof(fat_directory_structure));
         tempindex:=genfs_filesystem_get_using_cluster(fs,
         sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword);
         for j:=1 to tempindex.count do
          begin
           ii1:=tempindex.index[j-1] shr 1; ii2:=tempindex.index[j-1] mod 2;
           if(ii2=0) then
           (fs.fat12.entrypair+ii1)^.entry12.entry1:=0
           else if(ii2=1) then
           (fs.fat12.entrypair+ii1)^.entry12.entry2:=0;
           tempoffset:=(tempindex.index[j-1]-2)*tempnum1*tempnum2;
           k:=tempnum1*tempnum2 shr 9;
           while(k>0)do
            begin
             genfs_io_write(fs,clearcontent,fs.fat12.datastart+(k-1) shl 9,512);
             dec(k);
            end;
          end;
         j:=1;
         while(j<=inlist.count)do
          begin
           if(temppath=inlist.FilePath[j-1]) then break;
           inc(j);
          end;
         tempoffset:=inlist.FileOffset[j-1];
         genfs_io_read(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+inlist.FileDirSize[j-1]-
         sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         for j:=1 to sizeof(fat_directory_structure) do PByte(Pointer(@sdir)+j-1)^:=0;
         Pbyte(@sdir)^:=$E5;
         for j:=1 to inlist.FileDirSize[j-1] shr 5 do
         genfs_io_write(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+
         (j-1)*sizeof(fat_directory_structure),sizeof(fat_directory_structure));
        end;
      end;
     dec(i);
    end;
  end
 else if(fs.fsname=filesystem_fat16) then
  begin
   tempnum1:=fs.fat16.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat16.header.head.bpb_SectorPerCluster;
   i:=inlist.Count;
   while(i>0)do
    begin
     if(ismask) then
      begin
       if(genfs_mask_match(delpath,inlist.FilePath[i-1])) then
        begin
         genfs_io_read(fs,sdir,fs.fat16.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
         sizeof(fat_directory_structure),
         sizeof(fat_directory_structure));
         tempindex:=genfs_filesystem_get_using_cluster(fs,
         sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword);
         for j:=1 to tempindex.count do
          begin
           ii1:=tempindex.index[j-1] shr 1; ii2:=tempindex.index[j-1] mod 2;
           (fs.fat16.entrypair+ii1)^.entry16[ii2+1]:=0;
           tempoffset:=(tempindex.index[j-1]-2)*tempnum1*tempnum2;
           k:=tempnum1*tempnum2 shr 9;
           while(k>0)do
            begin
             genfs_io_write(fs,clearcontent,fs.fat16.datastart+(k-1) shl 9,512);
             dec(k);
            end;
          end;
         j:=1;
         while(j<=inlist.count)do
          begin
           if(temppath=inlist.FilePath[j-1]) then break;
           inc(j);
          end;
         tempoffset:=inlist.FileOffset[j-1];
         genfs_io_read(fs,sdir,fs.fat16.datastart+inlist.FileOffset[j-1]+inlist.FileDirSize[j-1]-
         sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         for j:=1 to sizeof(fat_directory_structure) do PByte(Pointer(@sdir)+j-1)^:=0;
         Pbyte(@sdir)^:=$E5;
         for j:=1 to inlist.FileDirSize[j-1] shr 5 do
         genfs_io_write(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+
         (j-1)*sizeof(fat_directory_structure),sizeof(fat_directory_structure));
        end;
      end
     else
      begin
       if(genfs_check_prefix(delpath,inlist.FilePath[i-1])) then
        begin
         genfs_io_read(fs,sdir,fs.fat16.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
         sizeof(fat_directory_structure),
         sizeof(fat_directory_structure));
         tempindex:=genfs_filesystem_get_using_cluster(fs,
         sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword);
         for j:=1 to tempindex.count do
          begin
           ii1:=tempindex.index[j-1] shr 1; ii2:=tempindex.index[j-1] mod 2;
           (fs.fat16.entrypair+ii1)^.entry16[ii2+1]:=0;
           tempoffset:=(tempindex.index[j-1]-2)*tempnum1*tempnum2;
           k:=tempnum1*tempnum2 shr 9;
           while(k>0)do
            begin
             genfs_io_write(fs,clearcontent,fs.fat16.datastart+(k-1) shl 9,512);
             dec(k);
            end;
          end;
         j:=1;
         while(j<=inlist.count)do
          begin
           if(temppath=inlist.FilePath[j-1]) then break;
           inc(j);
          end;
         tempoffset:=inlist.FileOffset[j-1];
         genfs_io_read(fs,sdir,fs.fat16.datastart+inlist.FileOffset[j-1]+inlist.FileDirSize[j-1]-
         sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         for j:=1 to sizeof(fat_directory_structure) do PByte(Pointer(@sdir)+j-1)^:=0;
         Pbyte(@sdir)^:=$E5;
         for j:=1 to inlist.FileDirSize[j-1] shr 5 do
         genfs_io_write(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+
         (j-1)*sizeof(fat_directory_structure),sizeof(fat_directory_structure));
        end;
      end;
     dec(i);
    end;
  end
 else if(fs.fsname=filesystem_fat32) then
  begin
   tempnum1:=fs.fat32.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat32.header.head.bpb_SectorPerCluster;
   i:=inlist.Count;
   while(i>0)do
    begin
     if(ismask) then
      begin
       if(genfs_mask_match(delpath,inlist.FilePath[i-1])) then
        begin
         genfs_io_read(fs,sdir,fs.fat32.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
         sizeof(fat_directory_structure),
         sizeof(fat_directory_structure));
         tempindex:=genfs_filesystem_get_using_cluster(fs,
         sdir.directoryfirstclusterhighword shl 32+sdir.directoryfirstclusterlowword);
         for j:=1 to tempindex.count do
          begin
           ii1:=tempindex.index[j-1] shr 1; ii2:=tempindex.index[j-1] mod 2;
           (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=0;
           tempoffset:=(tempindex.index[j-1]-2)*tempnum1*tempnum2;
           k:=tempnum1*tempnum2 shr 9;
           while(k>0)do
            begin
             genfs_io_write(fs,clearcontent,fs.fat32.datastart+(k-1) shl 9,512);
             dec(k);
            end;
          end;
         j:=1;
         while(j<=inlist.count)do
          begin
           if(temppath=inlist.FilePath[j-1]) then break;
           inc(j);
          end;
         tempoffset:=inlist.FileOffset[j-1];
         genfs_io_read(fs,sdir,fs.fat32.datastart+inlist.FileOffset[j-1]+inlist.FileDirSize[j-1]-
         sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         for j:=1 to sizeof(fat_directory_structure) do PByte(Pointer(@sdir)+j-1)^:=0;
         Pbyte(@sdir)^:=$E5;
         for j:=1 to inlist.FileDirSize[j-1] shr 5 do
         genfs_io_write(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+
         (j-1)*sizeof(fat_directory_structure),sizeof(fat_directory_structure));
        end;
      end
     else
      begin
       if(genfs_check_prefix(delpath,inlist.FilePath[i-1])) then
        begin
         genfs_io_read(fs,sdir,fs.fat32.datastart+inlist.FileOffset[i-1]+inlist.FileDirSize[i-1]-
         sizeof(fat_directory_structure),
         sizeof(fat_directory_structure));
         tempindex:=genfs_filesystem_get_using_cluster(fs,
         sdir.directoryfirstclusterhighword shl 32+sdir.directoryfirstclusterlowword);
         for j:=1 to tempindex.count do
          begin
           ii1:=tempindex.index[j-1] shr 1; ii2:=tempindex.index[j-1] mod 2;
           (fs.fat32.entrypair+ii1)^.entry32[ii2+1]:=0;
           tempoffset:=(tempindex.index[j-1]-2)*tempnum1*tempnum2;
           k:=tempnum1*tempnum2 shr 9;
           while(k>0)do
            begin
             genfs_io_write(fs,clearcontent,fs.fat32.datastart+(k-1) shl 9,512);
             dec(k);
            end;
          end;
         j:=1;
         while(j<=inlist.count)do
          begin
           if(temppath=inlist.FilePath[j-1]) then break;
           inc(j);
          end;
         tempoffset:=inlist.FileOffset[j-1];
         genfs_io_read(fs,sdir,fs.fat32.datastart+inlist.FileOffset[j-1]+inlist.FileDirSize[j-1]-
         sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         for j:=1 to sizeof(fat_directory_structure) do PByte(Pointer(@sdir)+j-1)^:=0;
         Pbyte(@sdir)^:=$E5;
         for j:=1 to inlist.FileDirSize[j-1] shr 5 do
         genfs_io_write(fs,sdir,fs.fat12.datastart+inlist.FileOffset[j-1]+
         (j-1)*sizeof(fat_directory_structure),sizeof(fat_directory_structure));
        end;
      end;
     dec(i);
    end;
  end;
 genfs_write(fs);
end;
{File System Extract Item}
procedure genfs_filesystem_extract(fs:genfs_filesystem;srcpath:UnicodeString;destpath:UnicodeString);
var i,j,index,size,tempnum1,tempnum2,tempindex,tempstorage,tempcount,tempoffset:SizeUInt;
    temppath,basepath:UnicodeString;
    templist:genfs_index_list;
    inlist:genfs_inner_path;
    sdir:fat_directory_structure;
    extcontent:array[1..512] of byte;
    exist:boolean;
    ismask:boolean;
    iobyte:byte=0;
begin
 for i:=1 to 512 do extcontent[i]:=0;
 i:=1; exist:=false;
 ismask:=genfs_is_mask(srcpath);
 inlist:=genfs_search_for_path(fs,'/');
 if(fs.fsname=filesystem_fat12) then
  begin
   tempnum1:=fs.fat12.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat12.header.head.bpb_SectorPerCluster;
   for i:=1 to inlist.Count do
    begin
     if(ismask=true) and (inlist.FileClass[i-1]<>fat_directory_volume) and
     (genfs_mask_match(srcpath,inlist.FilePath[i-1])) then
      begin
       exist:=true;
       basepath:=genfs_Extract_filepath(srcpath);
       temppath:=Copy(srcpath,length(basepath)+2,length(srcpath)-length(basepath)-1);
       if(inlist.FileClass[i-1]=fat_directory_directory) then
       CreateDir(destpath+'/'+temppath)
       else
        begin
         genfs_io_read(fs,sdir,fs.fat12.datastart+inlist.FileOffset[i-1],sizeof(fat_directory_structure));
         index:=sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword;
         size:=sdir.directoryfilesize;
         templist:=genfs_filesystem_get_using_cluster(fs,index);
         j:=1;
         if(size=0) then
          begin
           genfs_external_io_write(destpath+'/'+temppath,iobyte,0,0);
          end
         else
          begin
           tempindex:=templist.index[0]; tempstorage:=0;
           tempoffset:=0; tempcount:=size shr 9+1;
           while(tempcount>0)do
            begin
             if(tempstorage+512<=Size) then
              begin
               genfs_io_read(fs,extcontent,fs.fat12.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,512);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,512);
               inc(tempstorage,512);
              end
             else
              begin
               genfs_io_read(fs,extcontent,fs.fat12.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,size-tempstorage);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,size-tempstorage);
               tempstorage:=size;
              end;
             inc(tempoffset,1 shl 9);
             if(tempoffset=tempnum1*tempnum2) then
              begin
               tempindex:=templist.index[size shr 9+1-tempcount];
               tempoffset:=0;
              end;
             dec(tempcount);
            end;
          end;
        end;
      end
     else if(ismask=false) and (inlist.FileClass[i-1]<>fat_directory_volume)
     and (genfs_check_prefix(srcpath,inlist.FilePath[i-1])) then
      begin
       exist:=true;
       basepath:=genfs_extract_filepath(inlist.FilePath[i-1]);
       temppath:=Copy(inlist.FilePath[i-1],length(basepath)+2,length(inlist.FilePath[i-1])
       -length(basepath)-1);
       if(inlist.FileClass[i-1]=fat_directory_directory) then
       CreateDir(destpath+'/'+temppath)
       else
        begin
         genfs_io_read(fs,sdir,fs.fat12.datastart+inlist.FileOffset[i-1],sizeof(fat_directory_structure));
         index:=sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword;
         size:=sdir.directoryfilesize;
         templist:=genfs_filesystem_get_using_cluster(fs,index);
         j:=1;
         if(size=0) then
          begin
           genfs_external_io_write(destpath+'/'+temppath,iobyte,0,0);
          end
         else
          begin
           tempindex:=templist.index[0]; tempstorage:=0;
           tempoffset:=0; tempcount:=size shr 9+1;
           while(tempcount>0)do
            begin
             if(tempstorage+512<=Size) then
              begin
               genfs_io_read(fs,extcontent,fs.fat12.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,512);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,512);
               inc(tempstorage,512);
              end
             else
              begin
               genfs_io_read(fs,extcontent,fs.fat12.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,size-tempstorage);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,size-tempstorage);
               tempstorage:=size;
              end;
             inc(tempoffset,1 shl 9);
             if(tempoffset=tempnum1*tempnum2) then
              begin
               tempindex:=templist.index[size shr 9+1-tempcount];
               tempoffset:=0;
              end;
             dec(tempcount);
            end;
          end;
        end;
      end;
    end;
  end
 else if(fs.fsname=filesystem_fat16) then
  begin
   tempnum1:=fs.fat16.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat16.header.head.bpb_SectorPerCluster;
   for i:=1 to inlist.Count do
    begin
     if(ismask=true) and (inlist.FileClass[i-1]<>fat_directory_volume) and
     (genfs_mask_match(srcpath,inlist.FilePath[i-1])) then
      begin
       exist:=true;
       basepath:=genfs_Extract_filepath(srcpath);
       temppath:=Copy(srcpath,length(basepath)+2,length(srcpath)-length(basepath)-1);
       if(inlist.FileClass[i-1]=fat_directory_directory) then
       CreateDir(destpath+'/'+temppath)
       else
        begin
         genfs_io_read(fs,sdir,fs.fat16.datastart+inlist.FileOffset[i-1],sizeof(fat_directory_structure));
         index:=sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword;
         size:=sdir.directoryfilesize;
         templist:=genfs_filesystem_get_using_cluster(fs,index);
         j:=1;
         if(size=0) then
          begin
           genfs_external_io_write(destpath+'/'+temppath,iobyte,0,0);
          end
         else
          begin
           tempindex:=templist.index[0]; tempstorage:=0;
           tempoffset:=0; tempcount:=size shr 9+1;
           while(tempcount>0)do
            begin
             if(tempstorage+512<=Size) then
              begin
               genfs_io_read(fs,extcontent,fs.fat16.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,512);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,512);
               inc(tempstorage,512);
              end
             else
              begin
               genfs_io_read(fs,extcontent,fs.fat16.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,size-tempstorage);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,size-tempstorage);
               tempstorage:=size;
              end;
             inc(tempoffset,1 shl 9);
             if(tempoffset=tempnum1*tempnum2) then
              begin
               tempindex:=templist.index[size shr 9+1-tempcount];
               tempoffset:=0;
              end;
             dec(tempcount);
            end;
          end;
        end;
      end
     else if(ismask=false) and (inlist.FileClass[i-1]<>fat_directory_volume)
     and (genfs_check_prefix(srcpath,inlist.FilePath[i-1])) then
      begin
       exist:=true;
       basepath:=genfs_extract_filepath(inlist.FilePath[i-1]);
       temppath:=Copy(inlist.FilePath[i-1],length(basepath)+2,length(inlist.FilePath[i-1])
       -length(basepath)-1);
       if(inlist.FileClass[i-1]=fat_directory_directory) then
       CreateDir(destpath+'/'+temppath)
       else
        begin
         genfs_io_read(fs,sdir,fs.fat16.datastart+inlist.FileOffset[i-1],sizeof(fat_directory_structure));
         index:=sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword;
         size:=sdir.directoryfilesize;
         templist:=genfs_filesystem_get_using_cluster(fs,index);
         j:=1;
         if(size=0) then
          begin
           genfs_external_io_write(destpath+'/'+temppath,iobyte,0,0);
          end
         else
          begin
           tempindex:=templist.index[0]; tempstorage:=0;
           tempoffset:=0; tempcount:=size shr 9+1;
           while(tempcount>0)do
            begin
             if(tempstorage+512<=Size) then
              begin
               genfs_io_read(fs,extcontent,fs.fat16.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,512);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,512);
               inc(tempstorage,512);
              end
             else
              begin
               genfs_io_read(fs,extcontent,fs.fat16.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,size-tempstorage);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,size-tempstorage);
               tempstorage:=size;
              end;
             inc(tempoffset,1 shl 9);
             if(tempoffset=tempnum1*tempnum2) then
              begin
               tempindex:=templist.index[size shr 9+1-tempcount];
               tempoffset:=0;
              end;
             dec(tempcount);
            end;
          end;
        end;
      end;
    end;
  end
 else if(fs.fsname=filesystem_fat32) then
  begin
   tempnum1:=fs.fat32.header.head.bpb_bytesPerSector;
   tempnum2:=fs.fat32.header.head.bpb_SectorPerCluster;
   for i:=1 to inlist.Count do
    begin
     if(ismask) and (inlist.FileClass[i-1]<>fat_directory_volume) and
     (genfs_mask_match(srcpath,inlist.FilePath[i-1])) then
      begin
       exist:=true;
       basepath:=genfs_Extract_filepath(srcpath);
       temppath:=Copy(srcpath,length(basepath)+2,length(srcpath)-length(basepath)-1);
       if(inlist.FileClass[i-1]=fat_directory_directory) then
       CreateDir(destpath+'/'+temppath)
       else
        begin
         genfs_io_read(fs,sdir,fs.fat32.datastart+inlist.FileOffset[i-1]
         +inlist.FileDirSize[i-1]-sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         index:=sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword;
         size:=sdir.directoryfilesize;
         templist:=genfs_filesystem_get_using_cluster(fs,index);
         j:=1;
         if(size=0) then
          begin
           genfs_external_io_write(destpath+'/'+temppath,iobyte,0,0);
          end
         else
          begin
           tempindex:=templist.index[0]; tempstorage:=0;
           tempoffset:=0; tempcount:=size shr 9+1;
           while(tempcount>0)do
            begin
             if(tempstorage+512<=Size) then
              begin
               genfs_io_read(fs,extcontent,fs.fat32.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,512);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,512);
               inc(tempstorage,512);
              end
             else
              begin
               genfs_io_read(fs,extcontent,fs.fat32.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,size-tempstorage);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,size-tempstorage);
               tempstorage:=size;
              end;
             inc(tempoffset,1 shl 9);
             if(tempoffset=tempnum1*tempnum2) then
              begin
               tempindex:=templist.index[size shr 9+1-tempcount];
               tempoffset:=0;
              end;
             dec(tempcount);
            end;
          end;
        end;
      end
     else if(ismask=false) and (inlist.FileClass[i-1]<>fat_directory_volume)
     and (genfs_check_prefix(srcpath,inlist.FilePath[i-1])) then
      begin
       exist:=true;
       basepath:=genfs_extract_filepath(inlist.FilePath[i-1]);
       temppath:=Copy(inlist.FilePath[i-1],length(basepath)+2,length(inlist.FilePath[i-1])
       -length(basepath)-1);
       if(inlist.FileClass[i-1]=fat_directory_directory) then
       CreateDir(destpath+'/'+temppath)
       else
        begin
         genfs_io_read(fs,sdir,fs.fat32.datastart+inlist.FileOffset[i-1]
         +inlist.FileDirSize[i-1]-sizeof(fat_directory_structure),sizeof(fat_directory_structure));
         index:=sdir.directoryfirstclusterhighword shl 16+sdir.directoryfirstclusterlowword;
         size:=sdir.directoryfilesize;
         templist:=genfs_filesystem_get_using_cluster(fs,index);
         j:=1;
         if(size=0) then
          begin
           genfs_external_io_write(destpath+'/'+temppath,iobyte,0,0);
          end
         else
          begin
           tempindex:=templist.index[0]; tempstorage:=0;
           tempoffset:=0; tempcount:=size shr 9+1;
           while(tempcount>0)do
            begin
             if(tempstorage+512<=Size) then
              begin
               genfs_io_read(fs,extcontent,fs.fat32.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,512);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,512);
               inc(tempstorage,512);
              end
             else
              begin
               genfs_io_read(fs,extcontent,fs.fat32.datastart+
               (tempindex-2)*tempnum1*tempnum2+tempoffset,size-tempstorage);
               genfs_external_io_write(destpath+'/'+temppath,extcontent,tempstorage,size-tempstorage);
               tempstorage:=size;
              end;
             inc(tempoffset,1 shl 9);
             if(tempoffset=tempnum1*tempnum2) then
              begin
               tempindex:=templist.index[size shr 9+1-tempcount];
               tempoffset:=0;
              end;
             dec(tempcount);
            end;
          end;
        end;
      end;
    end;
  end
 else
  begin

  end;
 if(exist=false) then
  begin
   writeln('ERROR:The Extract Path does not exist in image.');
   readln;
   abort;
  end;
end;

end.

