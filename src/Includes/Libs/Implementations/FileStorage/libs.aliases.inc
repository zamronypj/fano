{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * redeclare all class types in unit inside Libs/FileStorage
 * directory
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)
TLocalDiskFile = LocalDiskFileImpl.TLocalDiskFile;
TLocalDiskDirectory = LocalDiskDirectoryImpl.TLocalDiskDirectory;
TLocalDiskStorage = LocalDiskStorageImpl.TLocalDiskStorage;
TLocalDiskStorageFactory = LocalDiskStorageFactoryImpl.TLocalDiskStorageFactory;

TCompositeFile = CompositeFileImpl.TCompositeFile;
TCompositeDirectory = CompositeDirectoryImpl.TCompositeDirectory;
TCompositeStorage = CompositeStorageImpl.TCompositeStorage;
TCompositeStorageFactory = CompositeStorageFactoryImpl.TCompositeStorageFactory;

TAmazonS3File = AmazonS3FileImpl.TAmazonS3File;
TAmazonS3Directory = AmazonS3DirectoryImpl.TAmazonS3Directory;
TAmazonS3Storage = AmazonS3StorageImpl.TAmazonS3Storage;