/**
 * @summary
 * BookNest database schema creation.
 * Creates all tables for library management and reading tracking functionality.
 *
 * @schema functional
 */

-- ============================================
-- TABLES CREATION
-- ============================================

/**
 * @table bookshelf
 * @multitenancy true
 * @softDelete true
 * @alias bsh
 */
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

/**
 * @table book
 * @multitenancy true
 * @softDelete true
 * @alias bk
 */
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

/**
 * @table bookReview
 * @multitenancy true
 * @softDelete true
 * @alias bkRvw
 */
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

/**
 * @table readingProgress
 * @multitenancy true
 * @softDelete true
 * @alias rdgPrg
 */
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

/**
 * @table readingGoal
 * @multitenancy true
 * @softDelete true
 * @alias rdgGl
 */
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
-- PRIMARY KEY CONSTRAINTS
-- ============================================

/**
 * @primaryKey pkBookshelf
 * @keyType Object
 */
ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [pkBookshelf] PRIMARY KEY CLUSTERED ([idBookshelf]);
GO

/**
 * @primaryKey pkBook
 * @keyType Object
 */
ALTER TABLE [dbo].[book]
ADD CONSTRAINT [pkBook] PRIMARY KEY CLUSTERED ([idBook]);
GO

/**
 * @primaryKey pkBookReview
 * @keyType Object
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [pkBookReview] PRIMARY KEY CLUSTERED ([idBookReview]);
GO

/**
 * @primaryKey pkReadingProgress
 * @keyType Object
 */
ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [pkReadingProgress] PRIMARY KEY CLUSTERED ([idReadingProgress]);
GO

/**
 * @primaryKey pkReadingGoal
 * @keyType Object
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [pkReadingGoal] PRIMARY KEY CLUSTERED ([idReadingGoal]);
GO

-- ============================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================

/**
 * @foreignKey fkBook_Bookshelf
 * @target dbo.bookshelf
 */
ALTER TABLE [dbo].[book]
ADD CONSTRAINT [fkBook_Bookshelf] FOREIGN KEY ([idBookshelf])
REFERENCES [dbo].[bookshelf]([idBookshelf]);
GO

/**
 * @foreignKey fkBookReview_Book
 * @target dbo.book
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [fkBookReview_Book] FOREIGN KEY ([idBook])
REFERENCES [dbo].[book]([idBook]);
GO

/**
 * @foreignKey fkReadingProgress_Book
 * @target dbo.book
 */
ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [fkReadingProgress_Book] FOREIGN KEY ([idBook])
REFERENCES [dbo].[book]([idBook]);
GO

-- ============================================
-- CHECK CONSTRAINTS
-- ============================================

/**
 * @check chkBookshelf_ShelfType
 * @enum {Lido} Read books
 * @enum {Lendo} Currently reading
 * @enum {Quero Ler} Want to read
 */
ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [chkBookshelf_ShelfType] CHECK ([shelfType] IN ('Lido', 'Lendo', 'Quero Ler'));
GO

/**
 * @check chkBookshelf_BookCount
 */
ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [chkBookshelf_BookCount] CHECK ([bookCount] >= 0);
GO

/**
 * @check chkBook_PublicationYear
 */
ALTER TABLE [dbo].[book]
ADD CONSTRAINT [chkBook_PublicationYear] CHECK ([publicationYear] IS NULL OR ([publicationYear] >= 1000 AND [publicationYear] <= YEAR(GETUTCDATE())));
GO

/**
 * @check chkBook_PageCount
 */
ALTER TABLE [dbo].[book]
ADD CONSTRAINT [chkBook_PageCount] CHECK ([pageCount] IS NULL OR [pageCount] >= 1);
GO

/**
 * @check chkBookReview_Rating
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [chkBookReview_Rating] CHECK ([rating] >= 0 AND [rating] <= 5 AND ([rating] * 2) = FLOOR([rating] * 2));
GO

/**
 * @check chkBookReview_Visibility
 * @enum {Pública} Public review
 * @enum {Privada} Private review
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [chkBookReview_Visibility] CHECK ([visibility] IN ('Pública', 'Privada'));
GO

/**
 * @check chkReadingProgress_CurrentPage
 */
ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [chkReadingProgress_CurrentPage] CHECK ([currentPage] >= 1);
GO

/**
 * @check chkReadingProgress_PercentComplete
 */
ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [chkReadingProgress_PercentComplete] CHECK ([percentComplete] >= 0 AND [percentComplete] <= 100);
GO

/**
 * @check chkReadingGoal_GoalType
 * @enum {Livros} Books goal
 * @enum {Páginas} Pages goal
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_GoalType] CHECK ([goalType] IN ('Livros', 'Páginas'));
GO

/**
 * @check chkReadingGoal_Period
 * @enum {Mensal} Monthly period
 * @enum {Trimestral} Quarterly period
 * @enum {Anual} Annual period
 * @enum {Personalizado} Custom period
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_Period] CHECK ([period] IN ('Mensal', 'Trimestral', 'Anual', 'Personalizado'));
GO

/**
 * @check chkReadingGoal_TargetQuantity
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_TargetQuantity] CHECK ([targetQuantity] >= 1);
GO

/**
 * @check chkReadingGoal_CurrentQuantity
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_CurrentQuantity] CHECK ([currentQuantity] >= 0);
GO

/**
 * @check chkReadingGoal_PercentComplete
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_PercentComplete] CHECK ([percentComplete] >= 0 AND [percentComplete] <= 100);
GO

/**
 * @check chkReadingGoal_Status
 * @enum {Em andamento} In progress
 * @enum {Concluída} Completed
 * @enum {Não concluída} Not completed
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [chkReadingGoal_Status] CHECK ([status] IN ('Em andamento', 'Concluída', 'Não concluída'));
GO

-- ============================================
-- DEFAULT CONSTRAINTS
-- ============================================

/**
 * @default dfBookshelf_BookCount
 */
ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_BookCount] DEFAULT (0) FOR [bookCount];
GO

/**
 * @default dfBookshelf_DateCreated
 */
ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

/**
 * @default dfBookshelf_DateModified
 */
ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

/**
 * @default dfBookshelf_Deleted
 */
ALTER TABLE [dbo].[bookshelf]
ADD CONSTRAINT [dfBookshelf_Deleted] DEFAULT (0) FOR [deleted];
GO

/**
 * @default dfBook_DateCreated
 */
ALTER TABLE [dbo].[book]
ADD CONSTRAINT [dfBook_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

/**
 * @default dfBook_DateModified
 */
ALTER TABLE [dbo].[book]
ADD CONSTRAINT [dfBook_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

/**
 * @default dfBook_Deleted
 */
ALTER TABLE [dbo].[book]
ADD CONSTRAINT [dfBook_Deleted] DEFAULT (0) FOR [deleted];
GO

/**
 * @default dfBookReview_Visibility
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_Visibility] DEFAULT ('Privada') FOR [visibility];
GO

/**
 * @default dfBookReview_DateCreated
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

/**
 * @default dfBookReview_DateModified
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

/**
 * @default dfBookReview_Deleted
 */
ALTER TABLE [dbo].[bookReview]
ADD CONSTRAINT [dfBookReview_Deleted] DEFAULT (0) FOR [deleted];
GO

/**
 * @default dfReadingProgress_DateRegistered
 */
ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [dfReadingProgress_DateRegistered] DEFAULT (GETUTCDATE()) FOR [dateRegistered];
GO

/**
 * @default dfReadingProgress_Deleted
 */
ALTER TABLE [dbo].[readingProgress]
ADD CONSTRAINT [dfReadingProgress_Deleted] DEFAULT (0) FOR [deleted];
GO

/**
 * @default dfReadingGoal_CurrentQuantity
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_CurrentQuantity] DEFAULT (0) FOR [currentQuantity];
GO

/**
 * @default dfReadingGoal_PercentComplete
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_PercentComplete] DEFAULT (0) FOR [percentComplete];
GO

/**
 * @default dfReadingGoal_Status
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_Status] DEFAULT ('Em andamento') FOR [status];
GO

/**
 * @default dfReadingGoal_NotificationsEnabled
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_NotificationsEnabled] DEFAULT (1) FOR [notificationsEnabled];
GO

/**
 * @default dfReadingGoal_DateCreated
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

/**
 * @default dfReadingGoal_DateModified
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

/**
 * @default dfReadingGoal_Deleted
 */
ALTER TABLE [dbo].[readingGoal]
ADD CONSTRAINT [dfReadingGoal_Deleted] DEFAULT (0) FOR [deleted];
GO

-- ============================================
-- INDEXES
-- ============================================

/**
 * @index ixBookshelf_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixBookshelf_Account]
ON [dbo].[bookshelf]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixBookshelf_User
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixBookshelf_User]
ON [dbo].[bookshelf]([idAccount], [idUser])
WHERE [deleted] = 0;
GO

/**
 * @index uqBookshelf_Account_User_ShelfType
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqBookshelf_Account_User_ShelfType]
ON [dbo].[bookshelf]([idAccount], [idUser], [shelfType])
WHERE [deleted] = 0;
GO

/**
 * @index ixBook_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixBook_Account]
ON [dbo].[book]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixBook_Bookshelf
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixBook_Bookshelf]
ON [dbo].[book]([idAccount], [idBookshelf])
INCLUDE ([title], [author], [dateCreated])
WHERE [deleted] = 0;
GO

/**
 * @index ixBook_User
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixBook_User]
ON [dbo].[book]([idAccount], [idUser])
WHERE [deleted] = 0;
GO

/**
 * @index ixBook_Title
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixBook_Title]
ON [dbo].[book]([idAccount], [title])
WHERE [deleted] = 0;
GO

/**
 * @index ixBook_Author
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixBook_Author]
ON [dbo].[book]([idAccount], [author])
WHERE [deleted] = 0;
GO

/**
 * @index ixBook_Genre
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixBook_Genre]
ON [dbo].[book]([idAccount], [genre])
WHERE [deleted] = 0 AND [genre] IS NOT NULL;
GO

/**
 * @index ixBookReview_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixBookReview_Account]
ON [dbo].[bookReview]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixBookReview_Book
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixBookReview_Book]
ON [dbo].[bookReview]([idAccount], [idBook])
WHERE [deleted] = 0;
GO

/**
 * @index uqBookReview_Account_User_Book
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqBookReview_Account_User_Book]
ON [dbo].[bookReview]([idAccount], [idUser], [idBook])
WHERE [deleted] = 0;
GO

/**
 * @index ixReadingProgress_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixReadingProgress_Account]
ON [dbo].[readingProgress]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixReadingProgress_Book
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixReadingProgress_Book]
ON [dbo].[readingProgress]([idAccount], [idBook])
INCLUDE ([currentPage], [percentComplete], [dateRegistered])
WHERE [deleted] = 0;
GO

/**
 * @index ixReadingGoal_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixReadingGoal_Account]
ON [dbo].[readingGoal]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixReadingGoal_User
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixReadingGoal_User]
ON [dbo].[readingGoal]([idAccount], [idUser])
INCLUDE ([status], [startDate], [endDate])
WHERE [deleted] = 0;
GO