-- ============================================
-- BOOKNEST DATABASE MIGRATION
-- Generated: 2024-01-15 10:00:00 UTC
-- ============================================

-- ============================================
-- STRUCTURE: TABLES CREATION
-- ============================================

CREATE TABLE [dbo].[bookshelf] (
  [idBookshelf] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [shelfType] VARCHAR(20) NOT NULL,
  [bookCount] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

CREATE TABLE [dbo].[book] (
  [idBook] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [idBookshelf] INTEGER NOT NULL,
  [title] NVARCHAR(200) NOT NULL,
  [author] NVARCHAR(100) NOT NULL,
  [publicationYear] INTEGER NULL,
  [genre] NVARCHAR(50) NULL,
  [coverUrl] NVARCHAR(500) NULL,
  [isbn] VARCHAR(20) NULL,
  [pageCount] INTEGER NULL,
  [startDate] DATE NULL,
  [completionDate] DATE NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

CREATE TABLE [dbo].[bookReview] (
  [idBookReview] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [idBook] INTEGER NOT NULL,
  [rating] NUMERIC(3, 1) NOT NULL,
  [reviewText] NVARCHAR(MAX) NULL,
  [visibility] VARCHAR(10) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

CREATE TABLE [dbo].[readingProgress] (
  [idReadingProgress] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [idBook] INTEGER NOT NULL,
  [currentPage] INTEGER NOT NULL,
  [percentComplete] NUMERIC(5, 2) NOT NULL,
  [notes] NVARCHAR(1000) NULL,
  [dateRegistered] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

CREATE TABLE [dbo].[readingGoal] (
  [idReadingGoal] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [goalType] VARCHAR(10) NOT NULL,
  [targetQuantity] INTEGER NOT NULL,
  [period] VARCHAR(20) NOT NULL,
  [startDate] DATE NOT NULL,
  [endDate] DATE NOT NULL,
  [currentQuantity] INTEGER NOT NULL,
  [percentComplete] NUMERIC(5, 2) NOT NULL,
  [status] VARCHAR(20) NOT NULL,
  [notificationsEnabled] BIT NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

-- ============================================
-- STRUCTURE: PRIMARY KEY CONSTRAINTS
-- ============================================

ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [pkBookshelf] PRIMARY KEY CLUSTERED ([idBookshelf]);
GO

ALTER TABLE [dbo].[book]
ADD CONSTRAINT [pkBook] PRIMARY KEY CLUSTERED ([idBook]);
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [pkBookReview] PRIMARY KEY CLUSTERED ([idBookReview]);
GO

ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [pkReadingProgress] PRIMARY KEY CLUSTERED ([idReadingProgress]);
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [pkReadingGoal] PRIMARY KEY CLUSTERED ([idReadingGoal]);
GO

-- ============================================
-- STRUCTURE: FOREIGN KEY CONSTRAINTS
-- ============================================

ALTER TABLE [dbo].[book]
ADD CONSTRAINT [fkBook_Bookshelf] FOREIGN KEY ([idBookshelf])
REFERENCES [dbo].[bookshelf]([idBookshelf]);
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [fkBookReview_Book] FOREIGN KEY ([idBook])
REFERENCES [dbo].[book]([idBook]);
GO

ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [fkReadingProgress_Book] FOREIGN KEY ([idBook])
REFERENCES [dbo].[book]([idBook]);
GO

-- ============================================
-- STRUCTURE: CHECK CONSTRAINTS
-- ============================================

ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [chkBookshelf_ShelfType] CHECK ([shelfType] IN ('Lido', 'Lendo', 'Quero Ler'));
GO

ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [chkBookshelf_BookCount] CHECK ([bookCount] >= 0);
GO

ALTER TABLE [dbo].[book]
ADD CONSTRAINT [chkBook_PublicationYear] CHECK ([publicationYear] IS NULL OR ([publicationYear] >= 1000 AND [publicationYear] <= YEAR(GETUTCDATE())));
GO

ALTER TABLE [dbo].[book]
ADD CONSTRAINT [chkBook_PageCount] CHECK ([pageCount] IS NULL OR [pageCount] >= 1);
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [chkBookReview_Rating] CHECK ([rating] >= 0 AND [rating] <= 5 AND ([rating] * 2) = FLOOR([rating] * 2));
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [chkBookReview_Visibility] CHECK ([visibility] IN ('Pública', 'Privada'));
GO

ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [chkReadingProgress_CurrentPage] CHECK ([currentPage] >= 1);
GO

ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [chkReadingProgress_PercentComplete] CHECK ([percentComplete] >= 0 AND [percentComplete] <= 100);
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_GoalType] CHECK ([goalType] IN ('Livros', 'Páginas'));
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_Period] CHECK ([period] IN ('Mensal', 'Trimestral', 'Anual', 'Personalizado'));
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_TargetQuantity] CHECK ([targetQuantity] >= 1);
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_CurrentQuantity] CHECK ([currentQuantity] >= 0);
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_PercentComplete] CHECK ([percentComplete] >= 0 AND [percentComplete] <= 100);
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_Status] CHECK ([status] IN ('Em andamento', 'Concluída', 'Não concluída'));
GO

-- ============================================
-- STRUCTURE: DEFAULT CONSTRAINTS
-- ============================================

ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_BookCount] DEFAULT (0) FOR [bookCount];
GO

ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_Deleted] DEFAULT (0) FOR [deleted];
GO

ALTER TABLE [dbo].[book]
ADD CONSTRAINT [dfBook_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

ALTER TABLE [dbo].[book]
ADD CONSTRAINT [dfBook_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

ALTER TABLE [dbo].[book]
ADD CONSTRAINT [dfBook_Deleted] DEFAULT (0) FOR [deleted];
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_Visibility] DEFAULT ('Privada') FOR [visibility];
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_Deleted] DEFAULT (0) FOR [deleted];
GO

ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [dfReadingProgress_DateRegistered] DEFAULT (GETUTCDATE()) FOR [dateRegistered];
GO

ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [dfReadingProgress_Deleted] DEFAULT (0) FOR [deleted];
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_CurrentQuantity] DEFAULT (0) FOR [currentQuantity];
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_PercentComplete] DEFAULT (0) FOR [percentComplete];
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_Status] DEFAULT ('Em andamento') FOR [status];
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_NotificationsEnabled] DEFAULT (1) FOR [notificationsEnabled];
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_Deleted] DEFAULT (0) FOR [deleted];
GO

-- ============================================
-- STRUCTURE: INDEXES
-- ============================================

CREATE NONCLUSTERED INDEX [ixBookshelf_Account]
ON [dbo].[bookshelf]([idAccount])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBookshelf_User]
ON [dbo].[bookshelf]([idAccount], [idUser])
WHERE [deleted] = 0;
GO

CREATE UNIQUE NONCLUSTERED INDEX [uqBookshelf_Account_User_ShelfType]
ON [dbo].[bookshelf]([idAccount], [idUser], [shelfType])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBook_Account]
ON [dbo].[book]([idAccount])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBook_Bookshelf]
ON [dbo].[book]([idAccount], [idBookshelf])
INCLUDE ([title], [author], [dateCreated])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBook_User]
ON [dbo].[book]([idAccount], [idUser])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBook_Title]
ON [dbo].[book]([idAccount], [title])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBook_Author]
ON [dbo].[book]([idAccount], [author])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBook_Genre]
ON [dbo].[book]([idAccount], [genre])
WHERE [deleted] = 0 AND [genre] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [ixBookReview_Account]
ON [dbo].[bookReview]([idAccount])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixBookReview_Book]
ON [dbo].[bookReview]([idAccount], [idBook])
WHERE [deleted] = 0;
GO

CREATE UNIQUE NONCLUSTERED INDEX [uqBookReview_Account_User_Book]
ON [dbo].[bookReview]([idAccount], [idUser], [idBook])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixReadingProgress_Account]
ON [dbo].[readingProgress]([idAccount])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixReadingProgress_Book]
ON [dbo].[readingProgress]([idAccount], [idBook])
INCLUDE ([currentPage], [percentComplete], [dateRegistered])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixReadingGoal_Account]
ON [dbo].[readingGoal]([idAccount])
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixReadingGoal_User]
ON [dbo].[readingGoal]([idAccount], [idUser])
INCLUDE ([status], [startDate], [endDate])
WHERE [deleted] = 0;
GO

-- ============================================
-- STORED PROCEDURES
-- ============================================

CREATE OR ALTER PROCEDURE [dbo].[spBookshelfInitialize]
  @idAccount INTEGER,
  @idUser INTEGER
AS
BEGIN
  SET NOCOUNT ON;

  IF @idAccount IS NULL
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF @idUser IS NULL
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
  END;

  IF EXISTS (SELECT 1 FROM [dbo].[bookshelf] WHERE [idAccount] = @idAccount AND [idUser] = @idUser AND [deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookshelvesAlreadyExist', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

    INSERT INTO [dbo].[bookshelf] ([idAccount], [idUser], [shelfType], [bookCount], [dateCreated], [dateModified], [deleted])
    VALUES
      (@idAccount, @idUser, 'Lido', 0, GETUTCDATE(), GETUTCDATE(), 0),
      (@idAccount, @idUser, 'Lendo', 0, GETUTCDATE(), GETUTCDATE(), 0),
      (@idAccount, @idUser, 'Quero Ler', 0, GETUTCDATE(), GETUTCDATE(), 0);

    SELECT
      [bsh].[idBookshelf],
      [bsh].[shelfType],
      [bsh].[bookCount]
    FROM [dbo].[bookshelf] [bsh]
    WHERE [bsh].[idAccount] = @idAccount
      AND [bsh].[idUser] = @idUser
      AND [bsh].[deleted] = 0
    ORDER BY
      CASE [bsh].[shelfType]
        WHEN 'Lendo' THEN 1
        WHEN 'Quero Ler' THEN 2
        WHEN 'Lido' THEN 3
      END;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[spBookshelfList]
  @idAccount INTEGER,
  @idUser INTEGER
AS
BEGIN
  SET NOCOUNT ON;

  IF @idAccount IS NULL
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF @idUser IS NULL
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
  END;

  SELECT
    [bsh].[idBookshelf],
    [bsh].[shelfType],
    [bsh].[bookCount]
  FROM [dbo].[bookshelf] [bsh]
  WHERE [bsh].[idAccount] = @idAccount
    AND [bsh].[idUser] = @idUser
    AND [bsh].[deleted] = 0
  ORDER BY
    CASE [bsh].[shelfType]
      WHEN 'Lendo' THEN 1
      WHEN 'Quero Ler' THEN 2
      WHEN 'Lido' THEN 3
    END;
END;
GO