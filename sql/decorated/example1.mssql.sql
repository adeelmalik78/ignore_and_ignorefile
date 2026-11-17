-- liquibase formatted sql

-- changeset amalik:1 splitStatements:false runWith:sqlcmd
IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;

-- changeset amalik:2 splitStatements:false runWith:sqlcmd
CREATE TABLE [Categories] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(100) NOT NULL,
    [Slug] nvarchar(120) NOT NULL,
    [ParentCategoryId] int NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    [CreatedBy] nvarchar(max) NULL,
    [UpdatedAt] datetimeoffset NULL,
    [UpdatedBy] nvarchar(max) NULL,
    CONSTRAINT [PK_Categories] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Categories_Categories_ParentCategoryId] FOREIGN KEY ([ParentCategoryId]) REFERENCES [Categories] ([Id]) ON DELETE NO ACTION
);

-- changeset amalik:3 splitStatements:false runWith:sqlcmd
CREATE TABLE [Customers] (
    [Id] int NOT NULL IDENTITY,
    [Email] nvarchar(254) NOT NULL,
    [DisplayName] nvarchar(200) NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    [CreatedBy] nvarchar(max) NULL,
    [UpdatedAt] datetimeoffset NULL,
    [UpdatedBy] nvarchar(max) NULL,
    [IsDeleted] bit NOT NULL,
    [DeletedAt] datetimeoffset NULL,
    CONSTRAINT [PK_Customers] PRIMARY KEY ([Id])
);

-- changeset amalik:4 splitStatements:false runWith:sqlcmd
CREATE TABLE [Products] (
    [Id] int NOT NULL IDENTITY,
    [Sku] nvarchar(64) NOT NULL,
    [Name] nvarchar(200) NOT NULL,
    [Description] nvarchar(2000) NULL,
    [CategoryId] int NOT NULL,
    [PriceAmount] decimal(18,2) NOT NULL,
    [PriceCurrency] nvarchar(3) NOT NULL,
    [IsActive] bit NOT NULL,
    [RowVersion] rowversion NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    [CreatedBy] nvarchar(max) NULL,
    [UpdatedAt] datetimeoffset NULL,
    [UpdatedBy] nvarchar(max) NULL,
    [IsDeleted] bit NOT NULL,
    [DeletedAt] datetimeoffset NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Products_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([Id]) ON DELETE NO ACTION
);

-- changeset amalik:5 splitStatements:false runWith:sqlcmd
CREATE TABLE [CustomerAddresses] (
    [Id] int NOT NULL IDENTITY,
    [Street] nvarchar(200) NOT NULL,
    [City] nvarchar(100) NOT NULL,
    [Region] nvarchar(100) NULL,
    [PostalCode] nvarchar(20) NOT NULL,
    [Country] nvarchar(2) NOT NULL,
    [Kind] nvarchar(20) NOT NULL,
    [CustomerId] int NOT NULL,
    CONSTRAINT [PK_CustomerAddresses] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_CustomerAddresses_Customers_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [Customers] ([Id]) ON DELETE CASCADE
);

-- changeset amalik:6 splitStatements:false runWith:sqlcmd
CREATE TABLE [Orders] (
    [Id] int NOT NULL IDENTITY,
    [OrderNumber] nvarchar(32) NOT NULL,
    [CustomerId] int NOT NULL,
    [Status] nvarchar(20) NOT NULL,
    [PlacedAt] datetimeoffset NOT NULL,
    [ShipStreet] nvarchar(200) NOT NULL,
    [ShipCity] nvarchar(100) NOT NULL,
    [ShipRegion] nvarchar(100) NULL,
    [ShipPostalCode] nvarchar(20) NOT NULL,
    [ShipCountry] nvarchar(2) NOT NULL,
    [ShipKind] nvarchar(20) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [TotalCurrency] nvarchar(3) NOT NULL,
    [RowVersion] rowversion NOT NULL,
    [CreatedAt] datetimeoffset NOT NULL,
    [CreatedBy] nvarchar(max) NULL,
    [UpdatedAt] datetimeoffset NULL,
    [UpdatedBy] nvarchar(max) NULL,
    CONSTRAINT [PK_Orders] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Orders_Customers_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [Customers] ([Id]) ON DELETE NO ACTION
);

-- changeset amalik:7 splitStatements:false runWith:sqlcmd
CREATE TABLE [Inventories] (
    [Id] int NOT NULL IDENTITY,
    [ProductId] int NOT NULL,
    [QuantityOnHand] int NOT NULL,
    [ReorderLevel] int NOT NULL,
    [RowVersion] rowversion NOT NULL,
    CONSTRAINT [PK_Inventories] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Inventories_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE CASCADE
);

-- changeset amalik:8 splitStatements:false runWith:sqlcmd
CREATE TABLE [OrderItems] (
    [Id] int NOT NULL IDENTITY,
    [OrderId] int NOT NULL,
    [ProductId] int NOT NULL,
    [Quantity] int NOT NULL,
    [UnitPriceAmount] decimal(18,2) NOT NULL,
    [UnitPriceCurrency] nvarchar(3) NOT NULL,
    CONSTRAINT [PK_OrderItems] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_OrderItems_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_OrderItems_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE NO ACTION
);

-- changeset amalik:9 splitStatements:false runWith:sqlcmd
CREATE TABLE [Payments] (
    [Id] int NOT NULL IDENTITY,
    [OrderId] int NOT NULL,
    [Provider] nvarchar(50) NOT NULL,
    [ProviderRef] nvarchar(100) NOT NULL,
    [AmountValue] decimal(18,2) NOT NULL,
    [AmountCurrency] nvarchar(3) NOT NULL,
    [CapturedAt] datetimeoffset NULL,
    [Status] nvarchar(20) NOT NULL,
    CONSTRAINT [PK_Payments] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Payments_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([Id]) ON DELETE CASCADE
);

-- changeset amalik:10 splitStatements:false runWith:sqlcmd
CREATE INDEX [IX_Categories_ParentCategoryId] ON [Categories] ([ParentCategoryId]);

-- changeset amalik:11 splitStatements:false runWith:sqlcmd
CREATE UNIQUE INDEX [IX_Categories_Slug] ON [Categories] ([Slug]);

-- changeset amalik:12 splitStatements:false runWith:sqlcmd
CREATE INDEX [IX_CustomerAddresses_CustomerId] ON [CustomerAddresses] ([CustomerId]);

-- changeset amalik:13 splitStatements:false runWith:sqlcmd
CREATE UNIQUE INDEX [IX_Customers_Email] ON [Customers] ([Email]);

-- changeset amalik:14 splitStatements:false runWith:sqlcmd
CREATE UNIQUE INDEX [IX_Inventories_ProductId] ON [Inventories] ([ProductId]);

-- changeset amalik:15 splitStatements:false runWith:sqlcmd
CREATE UNIQUE INDEX [IX_OrderItems_OrderId_ProductId] ON [OrderItems] ([OrderId], [ProductId]);

-- changeset amalik:16 splitStatements:false runWith:sqlcmd
CREATE INDEX [IX_OrderItems_ProductId] ON [OrderItems] ([ProductId]);

-- changeset amalik:17 splitStatements:false runWith:sqlcmd
CREATE INDEX [IX_Orders_CustomerId] ON [Orders] ([CustomerId]);

-- changeset amalik:18 splitStatements:false runWith:sqlcmd
CREATE UNIQUE INDEX [IX_Orders_OrderNumber] ON [Orders] ([OrderNumber]);

-- changeset amalik:19 splitStatements:false runWith:sqlcmd
CREATE UNIQUE INDEX [IX_Payments_OrderId] ON [Payments] ([OrderId]);

-- changeset amalik:20 splitStatements:false runWith:sqlcmd
CREATE INDEX [IX_Products_CategoryId] ON [Products] ([CategoryId]);

-- changeset amalik:21 splitStatements:false runWith:sqlcmd
CREATE UNIQUE INDEX [IX_Products_Sku] ON [Products] ([Sku]);

-- changeset amalik:22 splitStatements:false runWith:sqlcmd
INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260630153331_InitialCreate', N'10.0.0');

