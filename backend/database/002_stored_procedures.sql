/**
 * @summary
 * Stored procedures for BookNest library management.
 * Implements CRUD operations and business logic for all entities.
 */

-- ============================================
-- BOOKSHELF PROCEDURES
-- ============================================

/**
 * @summary
 * Initializes default bookshelves for a new user.
 *
 * @procedure spBookshelfInitialize
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/user (called automatically on user creation)
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 *
 * @testScenarios
 * - Valid initialization with all parameters
 * - Duplicate initialization handling
 * - Security validation failure scenarios
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookshelfInitialize]
  @idAccount INTEGER,
  @idUser INTEGER
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Verify required parameters
   * @throw {parameterRequired}
   */
  IF @idAccount IS NULL
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF @idUser IS NULL
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
  END;

  /**
   * @validation Check if bookshelves already exist
   * @throw {bookshelvesAlreadyExist}
   */
  IF EXISTS (SELECT 1 FROM [dbo].[bookshelf] WHERE [idAccount] = @idAccount AND [idUser] = @idUser AND [deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookshelvesAlreadyExist', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

    /**
     * @rule {BR-001,BR-002} Create three default bookshelves
     */
    INSERT INTO [dbo].[bookshelf] ([idAccount], [idUser], [shelfType], [bookCount], [dateCreated], [dateModified], [deleted])
    VALUES
      (@idAccount, @idUser, 'Lido', 0, GETUTCDATE(), GETUTCDATE(), 0),
      (@idAccount, @idUser, 'Lendo', 0, GETUTCDATE(), GETUTCDATE(), 0),
      (@idAccount, @idUser, 'Quero Ler', 0, GETUTCDATE(), GETUTCDATE(), 0);

    /**
     * @output {BookshelfList, 3, n}
     * @column {INT} idBookshelf - Bookshelf identifier
     * @column {VARCHAR} shelfType - Shelf type
     * @column {INT} bookCount - Number of books
     */
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

/**
 * @summary
 * Lists all bookshelves for a user.
 *
 * @procedure spBookshelfList
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/bookshelf
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 */
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

  /**
   * @output {BookshelfList, n, n}
   * @column {INT} idBookshelf
   * @column {VARCHAR} shelfType
   * @column {INT} bookCount
   */
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

-- ============================================
-- BOOK PROCEDURES
-- ============================================

/**
 * @summary
 * Creates a new book in a bookshelf.
 *
 * @procedure spBookCreate
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/book
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBookshelf - Bookshelf identifier
 * @param {NVARCHAR} title - Book title
 * @param {NVARCHAR} author - Book author
 * @param {INT} publicationYear - Publication year (optional)
 * @param {NVARCHAR} genre - Book genre (optional)
 * @param {NVARCHAR} coverUrl - Cover image URL (optional)
 * @param {VARCHAR} isbn - ISBN code (optional)
 * @param {INT} pageCount - Number of pages (optional)
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookCreate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBookshelf INTEGER,
  @title NVARCHAR(200),
  @author NVARCHAR(100),
  @publicationYear INTEGER = NULL,
  @genre NVARCHAR(50) = NULL,
  @coverUrl NVARCHAR(500) = NULL,
  @isbn VARCHAR(20) = NULL,
  @pageCount INTEGER = NULL
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

  IF @idBookshelf IS NULL
  BEGIN
    ;THROW 51000, 'idBookshelfRequired', 1;
  END;

  /**
   * @validation Title validation
   * @throw {titleRequired}
   */
  IF @title IS NULL OR LEN(LTRIM(RTRIM(@title))) = 0
  BEGIN
    ;THROW 51000, 'titleRequired', 1;
  END;

  /**
   * @validation Author validation
   * @throw {authorRequired}
   */
  IF @author IS NULL OR LEN(LTRIM(RTRIM(@author))) = 0
  BEGIN
    ;THROW 51000, 'authorRequired', 1;
  END;

  /**
   * @validation Bookshelf existence
   * @throw {bookshelfDoesntExist}
   */
  IF NOT EXISTS (SELECT 1 FROM [dbo].[bookshelf] [bsh] WHERE [bsh].[idBookshelf] = @idBookshelf AND [bsh].[idAccount] = @idAccount AND [bsh].[idUser] = @idUser AND [bsh].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookshelfDoesntExist', 1;
  END;

  /**
   * @validation Publication year range
   * @throw {publicationYearInvalid}
   */
  IF @publicationYear IS NOT NULL AND (@publicationYear < 1000 OR @publicationYear > YEAR(GETUTCDATE()))
  BEGIN
    ;THROW 51000, 'publicationYearInvalid', 1;
  END;

  /**
   * @validation Page count
   * @throw {pageCountInvalid}
   */
  IF @pageCount IS NOT NULL AND @pageCount < 1
  BEGIN
    ;THROW 51000, 'pageCountInvalid', 1;
  END;

  DECLARE @newIdBook INTEGER;
  DECLARE @shelfType VARCHAR(20);
  DECLARE @startDate DATE = NULL;

  SELECT @shelfType = [bsh].[shelfType]
  FROM [dbo].[bookshelf] [bsh]
  WHERE [bsh].[idBookshelf] = @idBookshelf
    AND [bsh].[idAccount] = @idAccount;

  /**
   * @rule {BR-005} Set start date if adding to 'Lendo' shelf
   */
  IF @shelfType = 'Lendo'
  BEGIN
    SET @startDate = CAST(GETUTCDATE() AS DATE);
  END;

  BEGIN TRY
    BEGIN TRAN;

    INSERT INTO [dbo].[book] ([idAccount], [idUser], [idBookshelf], [title], [author], [publicationYear], [genre], [coverUrl], [isbn], [pageCount], [startDate], [dateCreated], [dateModified], [deleted])
    VALUES (@idAccount, @idUser, @idBookshelf, @title, @author, @publicationYear, @genre, @coverUrl, @isbn, @pageCount, @startDate, GETUTCDATE(), GETUTCDATE(), 0);

    SET @newIdBook = SCOPE_IDENTITY();

    /**
     * @rule {DF-008} Update bookshelf book count
     */
    UPDATE [dbo].[bookshelf]
    SET [bookCount] = [bookCount] + 1,
        [dateModified] = GETUTCDATE()
    WHERE [idBookshelf] = @idBookshelf
      AND [idAccount] = @idAccount;

    /**
     * @output {BookCreated, 1, n}
     * @column {INT} idBook
     * @column {NVARCHAR} title
     * @column {NVARCHAR} author
     * @column {DATE} startDate
     */
    SELECT
      [bk].[idBook],
      [bk].[title],
      [bk].[author],
      [bk].[startDate]
    FROM [dbo].[book] [bk]
    WHERE [bk].[idBook] = @newIdBook;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

/**
 * @summary
 * Lists books in a bookshelf.
 *
 * @procedure spBookList
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/book
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBookshelf - Bookshelf identifier (optional)
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookList]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBookshelf INTEGER = NULL
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

  /**
   * @output {BookList, n, n}
   * @column {INT} idBook
   * @column {INT} idBookshelf
   * @column {VARCHAR} shelfType
   * @column {NVARCHAR} title
   * @column {NVARCHAR} author
   * @column {INT} publicationYear
   * @column {NVARCHAR} genre
   * @column {NVARCHAR} coverUrl
   * @column {VARCHAR} isbn
   * @column {INT} pageCount
   * @column {DATE} startDate
   * @column {DATE} completionDate
   * @column {DATETIME2} dateCreated
   */
  SELECT
    [bk].[idBook],
    [bk].[idBookshelf],
    [bsh].[shelfType],
    [bk].[title],
    [bk].[author],
    [bk].[publicationYear],
    [bk].[genre],
    [bk].[coverUrl],
    [bk].[isbn],
    [bk].[pageCount],
    [bk].[startDate],
    [bk].[completionDate],
    [bk].[dateCreated]
  FROM [dbo].[book] [bk]
    JOIN [dbo].[bookshelf] [bsh] ON ([bsh].[idAccount] = [bk].[idAccount] AND [bsh].[idBookshelf] = [bk].[idBookshelf])
  WHERE [bk].[idAccount] = @idAccount
    AND [bk].[idUser] = @idUser
    AND [bk].[deleted] = 0
    AND (@idBookshelf IS NULL OR [bk].[idBookshelf] = @idBookshelf)
  ORDER BY [bk].[dateCreated] DESC;
END;
GO

/**
 * @summary
 * Gets a specific book details.
 *
 * @procedure spBookGet
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/book/:id
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookGet]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  /**
   * @validation Book existence
   * @throw {bookDoesntExist}
   */
  IF NOT EXISTS (SELECT 1 FROM [dbo].[book] [bk] WHERE [bk].[idBook] = @idBook AND [bk].[idAccount] = @idAccount AND [bk].[idUser] = @idUser AND [bk].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookDoesntExist', 1;
  END;

  /**
   * @output {BookDetail, 1, n}
   * @column {INT} idBook
   * @column {INT} idBookshelf
   * @column {VARCHAR} shelfType
   * @column {NVARCHAR} title
   * @column {NVARCHAR} author
   * @column {INT} publicationYear
   * @column {NVARCHAR} genre
   * @column {NVARCHAR} coverUrl
   * @column {VARCHAR} isbn
   * @column {INT} pageCount
   * @column {DATE} startDate
   * @column {DATE} completionDate
   * @column {DATETIME2} dateCreated
   */
  SELECT
    [bk].[idBook],
    [bk].[idBookshelf],
    [bsh].[shelfType],
    [bk].[title],
    [bk].[author],
    [bk].[publicationYear],
    [bk].[genre],
    [bk].[coverUrl],
    [bk].[isbn],
    [bk].[pageCount],
    [bk].[startDate],
    [bk].[completionDate],
    [bk].[dateCreated]
  FROM [dbo].[book] [bk]
    JOIN [dbo].[bookshelf] [bsh] ON ([bsh].[idAccount] = [bk].[idAccount] AND [bsh].[idBookshelf] = [bk].[idBookshelf])
  WHERE [bk].[idBook] = @idBook
    AND [bk].[idAccount] = @idAccount
    AND [bk].[idUser] = @idUser
    AND [bk].[deleted] = 0;
END;
GO

/**
 * @summary
 * Updates book information.
 *
 * @procedure spBookUpdate
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - PUT /api/v1/internal/book/:id
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 * @param {NVARCHAR} title - Book title
 * @param {NVARCHAR} author - Book author
 * @param {INT} publicationYear - Publication year (optional)
 * @param {NVARCHAR} genre - Book genre (optional)
 * @param {NVARCHAR} coverUrl - Cover image URL (optional)
 * @param {VARCHAR} isbn - ISBN code (optional)
 * @param {INT} pageCount - Number of pages (optional)
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookUpdate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER,
  @title NVARCHAR(200),
  @author NVARCHAR(100),
  @publicationYear INTEGER = NULL,
  @genre NVARCHAR(50) = NULL,
  @coverUrl NVARCHAR(500) = NULL,
  @isbn VARCHAR(20) = NULL,
  @pageCount INTEGER = NULL
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  IF @title IS NULL OR LEN(LTRIM(RTRIM(@title))) = 0
  BEGIN
    ;THROW 51000, 'titleRequired', 1;
  END;

  IF @author IS NULL OR LEN(LTRIM(RTRIM(@author))) = 0
  BEGIN
    ;THROW 51000, 'authorRequired', 1;
  END;

  IF NOT EXISTS (SELECT 1 FROM [dbo].[book] [bk] WHERE [bk].[idBook] = @idBook AND [bk].[idAccount] = @idAccount AND [bk].[idUser] = @idUser AND [bk].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookDoesntExist', 1;
  END;

  IF @publicationYear IS NOT NULL AND (@publicationYear < 1000 OR @publicationYear > YEAR(GETUTCDATE()))
  BEGIN
    ;THROW 51000, 'publicationYearInvalid', 1;
  END;

  IF @pageCount IS NOT NULL AND @pageCount < 1
  BEGIN
    ;THROW 51000, 'pageCountInvalid', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

    UPDATE [dbo].[book]
    SET [title] = @title,
        [author] = @author,
        [publicationYear] = @publicationYear,
        [genre] = @genre,
        [coverUrl] = @coverUrl,
        [isbn] = @isbn,
        [pageCount] = @pageCount,
        [dateModified] = GETUTCDATE()
    WHERE [idBook] = @idBook
      AND [idAccount] = @idAccount
      AND [idUser] = @idUser;

    /**
     * @output {BookUpdated, 1, n}
     * @column {INT} idBook
     * @column {NVARCHAR} title
     * @column {NVARCHAR} author
     */
    SELECT
      [bk].[idBook],
      [bk].[title],
      [bk].[author]
    FROM [dbo].[book] [bk]
    WHERE [bk].[idBook] = @idBook;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

/**
 * @summary
 * Moves a book between bookshelves.
 *
 * @procedure spBookMove
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - PATCH /api/v1/internal/book/:id/move
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 * @param {INT} idBookshelfDestination - Destination bookshelf identifier
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookMove]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER,
  @idBookshelfDestination INTEGER
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  IF @idBookshelfDestination IS NULL
  BEGIN
    ;THROW 51000, 'idBookshelfDestinationRequired', 1;
  END;

  DECLARE @idBookshelfOrigin INTEGER;
  DECLARE @shelfTypeDestination VARCHAR(20);
  DECLARE @startDate DATE;
  DECLARE @completionDate DATE;

  /**
   * @validation Book existence
   * @throw {bookDoesntExist}
   */
  IF NOT EXISTS (SELECT 1 FROM [dbo].[book] [bk] WHERE [bk].[idBook] = @idBook AND [bk].[idAccount] = @idAccount AND [bk].[idUser] = @idUser AND [bk].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookDoesntExist', 1;
  END;

  /**
   * @validation Destination bookshelf existence
   * @throw {bookshelfDoesntExist}
   */
  IF NOT EXISTS (SELECT 1 FROM [dbo].[bookshelf] [bsh] WHERE [bsh].[idBookshelf] = @idBookshelfDestination AND [bsh].[idAccount] = @idAccount AND [bsh].[idUser] = @idUser AND [bsh].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookshelfDoesntExist', 1;
  END;

  SELECT @idBookshelfOrigin = [bk].[idBookshelf]
  FROM [dbo].[book] [bk]
  WHERE [bk].[idBook] = @idBook
    AND [bk].[idAccount] = @idAccount;

  /**
   * @validation Same bookshelf check
   * @throw {sameBookshelfMove}
   */
  IF @idBookshelfOrigin = @idBookshelfDestination
  BEGIN
    ;THROW 51000, 'sameBookshelfMove', 1;
  END;

  SELECT @shelfTypeDestination = [bsh].[shelfType]
  FROM [dbo].[bookshelf] [bsh]
  WHERE [bsh].[idBookshelf] = @idBookshelfDestination
    AND [bsh].[idAccount] = @idAccount;

  SELECT @startDate = [bk].[startDate]
  FROM [dbo].[book] [bk]
  WHERE [bk].[idBook] = @idBook
    AND [bk].[idAccount] = @idAccount;

  /**
   * @rule {BR-007} Set start date when moving to 'Lendo'
   */
  IF @shelfTypeDestination = 'Lendo' AND @startDate IS NULL
  BEGIN
    SET @startDate = CAST(GETUTCDATE() AS DATE);
  END;

  /**
   * @rule {BR-008} Set completion date when moving to 'Lido'
   */
  IF @shelfTypeDestination = 'Lido'
  BEGIN
    SET @completionDate = CAST(GETUTCDATE() AS DATE);
  END;

  BEGIN TRY
    BEGIN TRAN;

    UPDATE [dbo].[book]
    SET [idBookshelf] = @idBookshelfDestination,
        [startDate] = @startDate,
        [completionDate] = @completionDate,
        [dateModified] = GETUTCDATE()
    WHERE [idBook] = @idBook
      AND [idAccount] = @idAccount;

    /**
     * @rule {DF-015} Update book counts in both bookshelves
     */
    UPDATE [dbo].[bookshelf]
    SET [bookCount] = [bookCount] - 1,
        [dateModified] = GETUTCDATE()
    WHERE [idBookshelf] = @idBookshelfOrigin
      AND [idAccount] = @idAccount;

    UPDATE [dbo].[bookshelf]
    SET [bookCount] = [bookCount] + 1,
        [dateModified] = GETUTCDATE()
    WHERE [idBookshelf] = @idBookshelfDestination
      AND [idAccount] = @idAccount;

    /**
     * @output {BookMoved, 1, n}
     * @column {INT} idBook
     * @column {INT} idBookshelf
     * @column {VARCHAR} shelfType
     * @column {DATE} startDate
     * @column {DATE} completionDate
     */
    SELECT
      [bk].[idBook],
      [bk].[idBookshelf],
      [bsh].[shelfType],
      [bk].[startDate],
      [bk].[completionDate]
    FROM [dbo].[book] [bk]
      JOIN [dbo].[bookshelf] [bsh] ON ([bsh].[idAccount] = [bk].[idAccount] AND [bsh].[idBookshelf] = [bk].[idBookshelf])
    WHERE [bk].[idBook] = @idBook
      AND [bk].[idAccount] = @idAccount;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

/**
 * @summary
 * Deletes a book (soft delete).
 *
 * @procedure spBookDelete
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - DELETE /api/v1/internal/book/:id
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookDelete]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  DECLARE @idBookshelf INTEGER;

  IF NOT EXISTS (SELECT 1 FROM [dbo].[book] [bk] WHERE [bk].[idBook] = @idBook AND [bk].[idAccount] = @idAccount AND [bk].[idUser] = @idUser AND [bk].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookDoesntExist', 1;
  END;

  SELECT @idBookshelf = [bk].[idBookshelf]
  FROM [dbo].[book] [bk]
  WHERE [bk].[idBook] = @idBook
    AND [bk].[idAccount] = @idAccount;

  BEGIN TRY
    BEGIN TRAN;

    UPDATE [dbo].[book]
    SET [deleted] = 1,
        [dateModified] = GETUTCDATE()
    WHERE [idBook] = @idBook
      AND [idAccount] = @idAccount;

    UPDATE [dbo].[bookshelf]
    SET [bookCount] = [bookCount] - 1,
        [dateModified] = GETUTCDATE()
    WHERE [idBookshelf] = @idBookshelf
      AND [idAccount] = @idAccount;

    SELECT 1 AS [success];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

-- ============================================
-- BOOK REVIEW PROCEDURES
-- ============================================

/**
 * @summary
 * Creates or updates a book review.
 *
 * @procedure spBookReviewUpsert
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/book/:id/review
 * - PUT /api/v1/internal/book/:id/review
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 * @param {NUMERIC} rating - Rating (0-5)
 * @param {NVARCHAR} reviewText - Review text (optional)
 * @param {VARCHAR} visibility - Visibility (Pública/Privada)
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookReviewUpsert]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER,
  @rating NUMERIC(3, 1),
  @reviewText NVARCHAR(MAX) = NULL,
  @visibility VARCHAR(10)
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  /**
   * @validation Rating validation
   * @throw {ratingInvalid}
   */
  IF @rating IS NULL OR @rating < 0 OR @rating > 5 OR (@rating * 2) <> FLOOR(@rating * 2)
  BEGIN
    ;THROW 51000, 'ratingInvalid', 1;
  END;

  /**
   * @validation Visibility validation
   * @throw {visibilityInvalid}
   */
  IF @visibility IS NULL OR @visibility NOT IN ('Pública', 'Privada')
  BEGIN
    ;THROW 51000, 'visibilityInvalid', 1;
  END;

  /**
   * @validation Book existence
   * @throw {bookDoesntExist}
   */
  IF NOT EXISTS (SELECT 1 FROM [dbo].[book] [bk] WHERE [bk].[idBook] = @idBook AND [bk].[idAccount] = @idAccount AND [bk].[idUser] = @idUser AND [bk].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'bookDoesntExist', 1;
  END;

  /**
   * @validation Review text length
   * @throw {reviewTextTooLong}
   */
  IF @reviewText IS NOT NULL AND LEN(@reviewText) > 5000
  BEGIN
    ;THROW 51000, 'reviewTextTooLong', 1;
  END;

  DECLARE @existingIdReview INTEGER;
  DECLARE @newIdReview INTEGER;

  SELECT @existingIdReview = [bkRvw].[idBookReview]
  FROM [dbo].[bookReview] [bkRvw]
  WHERE [bkRvw].[idBook] = @idBook
    AND [bkRvw].[idAccount] = @idAccount
    AND [bkRvw].[idUser] = @idUser
    AND [bkRvw].[deleted] = 0;

  BEGIN TRY
    BEGIN TRAN;

    /**
     * @rule {BR-012} One review per user per book
     */
    IF @existingIdReview IS NOT NULL
    BEGIN
      UPDATE [dbo].[bookReview]
      SET [rating] = @rating,
          [reviewText] = @reviewText,
          [visibility] = @visibility,
          [dateModified] = GETUTCDATE()
      WHERE [idBookReview] = @existingIdReview
        AND [idAccount] = @idAccount;

      SET @newIdReview = @existingIdReview;
    END
    ELSE
    BEGIN
      INSERT INTO [dbo].[bookReview] ([idAccount], [idUser], [idBook], [rating], [reviewText], [visibility], [dateCreated], [dateModified], [deleted])
      VALUES (@idAccount, @idUser, @idBook, @rating, @reviewText, @visibility, GETUTCDATE(), GETUTCDATE(), 0);

      SET @newIdReview = SCOPE_IDENTITY();
    END;

    /**
     * @output {BookReviewUpserted, 1, n}
     * @column {INT} idBookReview
     * @column {INT} idBook
     * @column {NUMERIC} rating
     * @column {VARCHAR} visibility
     * @column {DATETIME2} dateCreated
     * @column {DATETIME2} dateModified
     */
    SELECT
      [bkRvw].[idBookReview],
      [bkRvw].[idBook],
      [bkRvw].[rating],
      [bkRvw].[visibility],
      [bkRvw].[dateCreated],
      [bkRvw].[dateModified]
    FROM [dbo].[bookReview] [bkRvw]
    WHERE [bkRvw].[idBookReview] = @newIdReview;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

/**
 * @summary
 * Gets a book review.
 *
 * @procedure spBookReviewGet
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/book/:id/review
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookReviewGet]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  /**
   * @output {BookReviewDetail, 1, n}
   * @column {INT} idBookReview
   * @column {INT} idBook
   * @column {NUMERIC} rating
   * @column {NVARCHAR} reviewText
   * @column {VARCHAR} visibility
   * @column {DATETIME2} dateCreated
   * @column {DATETIME2} dateModified
   */
  SELECT
    [bkRvw].[idBookReview],
    [bkRvw].[idBook],
    [bkRvw].[rating],
    [bkRvw].[reviewText],
    [bkRvw].[visibility],
    [bkRvw].[dateCreated],
    [bkRvw].[dateModified]
  FROM [dbo].[bookReview] [bkRvw]
  WHERE [bkRvw].[idBook] = @idBook
    AND [bkRvw].[idAccount] = @idAccount
    AND [bkRvw].[idUser] = @idUser
    AND [bkRvw].[deleted] = 0;
END;
GO

/**
 * @summary
 * Deletes a book review.
 *
 * @procedure spBookReviewDelete
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - DELETE /api/v1/internal/book/:id/review
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 */
CREATE OR ALTER PROCEDURE [dbo].[spBookReviewDelete]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  IF NOT EXISTS (SELECT 1 FROM [dbo].[bookReview] [bkRvw] WHERE [bkRvw].[idBook] = @idBook AND [bkRvw].[idAccount] = @idAccount AND [bkRvw].[idUser] = @idUser AND [bkRvw].[deleted] = 0)
  BEGIN
    ;THROW 51000, 'reviewDoesntExist', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

    UPDATE [dbo].[bookReview]
    SET [deleted] = 1,
        [dateModified] = GETUTCDATE()
    WHERE [idBook] = @idBook
      AND [idAccount] = @idAccount
      AND [idUser] = @idUser;

    SELECT 1 AS [success];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

-- ============================================
-- READING PROGRESS PROCEDURES
-- ============================================

/**
 * @summary
 * Creates a reading progress entry.
 *
 * @procedure spReadingProgressCreate
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/book/:id/progress
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 * @param {INT} currentPage - Current page
 * @param {NVARCHAR} notes - Progress notes (optional)
 */
CREATE OR ALTER PROCEDURE [dbo].[spReadingProgressCreate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER,
  @currentPage INTEGER,
  @notes NVARCHAR(1000) = NULL
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  /**
   * @validation Current page validation
   * @throw {currentPageInvalid}
   */
  IF @currentPage IS NULL OR @currentPage < 1
  BEGIN
    ;THROW 51000, 'currentPageInvalid', 1;
  END;

  DECLARE @shelfType VARCHAR(20);
  DECLARE @pageCount INTEGER;
  DECLARE @percentComplete NUMERIC(5, 2);

  /**
   * @validation Book must be in 'Lendo' shelf
   * @throw {bookNotInReadingShelf}
   */
  SELECT @shelfType = [bsh].[shelfType], @pageCount = [bk].[pageCount]
  FROM [dbo].[book] [bk]
    JOIN [dbo].[bookshelf] [bsh] ON ([bsh].[idAccount] = [bk].[idAccount] AND [bsh].[idBookshelf] = [bk].[idBookshelf])
  WHERE [bk].[idBook] = @idBook
    AND [bk].[idAccount] = @idAccount
    AND [bk].[idUser] = @idUser
    AND [bk].[deleted] = 0;

  IF @shelfType IS NULL
  BEGIN
    ;THROW 51000, 'bookDoesntExist', 1;
  END;

  /**
   * @rule {BR-016} Progress only for books in 'Lendo' shelf
   */
  IF @shelfType <> 'Lendo'
  BEGIN
    ;THROW 51000, 'bookNotInReadingShelf', 1;
  END;

  /**
   * @validation Current page vs total pages
   * @throw {currentPageExceedsTotal}
   */
  IF @pageCount IS NOT NULL AND @currentPage > @pageCount
  BEGIN
    ;THROW 51000, 'currentPageExceedsTotal', 1;
  END;

  /**
   * @rule {RU-052} Calculate percent complete
   */
  IF @pageCount IS NOT NULL AND @pageCount > 0
  BEGIN
    SET @percentComplete = CAST(@currentPage AS NUMERIC(5, 2)) / CAST(@pageCount AS NUMERIC(5, 2)) * 100;
    IF @percentComplete > 100
      SET @percentComplete = 100;
  END
  ELSE
  BEGIN
    SET @percentComplete = 0;
  END;

  DECLARE @newIdProgress INTEGER;

  BEGIN TRY
    BEGIN TRAN;

    INSERT INTO [dbo].[readingProgress] ([idAccount], [idUser], [idBook], [currentPage], [percentComplete], [notes], [dateRegistered], [deleted])
    VALUES (@idAccount, @idUser, @idBook, @currentPage, @percentComplete, @notes, GETUTCDATE(), 0);

    SET @newIdProgress = SCOPE_IDENTITY();

    /**
     * @output {ReadingProgressCreated, 1, n}
     * @column {INT} idReadingProgress
     * @column {INT} idBook
     * @column {INT} currentPage
     * @column {NUMERIC} percentComplete
     * @column {DATETIME2} dateRegistered
     */
    SELECT
      [rdgPrg].[idReadingProgress],
      [rdgPrg].[idBook],
      [rdgPrg].[currentPage],
      [rdgPrg].[percentComplete],
      [rdgPrg].[dateRegistered]
    FROM [dbo].[readingProgress] [rdgPrg]
    WHERE [rdgPrg].[idReadingProgress] = @newIdProgress;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

/**
 * @summary
 * Lists reading progress history for a book.
 *
 * @procedure spReadingProgressList
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/book/:id/progress
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {INT} idBook - Book identifier
 */
CREATE OR ALTER PROCEDURE [dbo].[spReadingProgressList]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idBook INTEGER
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

  IF @idBook IS NULL
  BEGIN
    ;THROW 51000, 'idBookRequired', 1;
  END;

  /**
   * @output {ReadingProgressList, n, n}
   * @column {INT} idReadingProgress
   * @column {INT} currentPage
   * @column {NUMERIC} percentComplete
   * @column {NVARCHAR} notes
   * @column {DATETIME2} dateRegistered
   */
  SELECT
    [rdgPrg].[idReadingProgress],
    [rdgPrg].[currentPage],
    [rdgPrg].[percentComplete],
    [rdgPrg].[notes],
    [rdgPrg].[dateRegistered]
  FROM [dbo].[readingProgress] [rdgPrg]
  WHERE [rdgPrg].[idBook] = @idBook
    AND [rdgPrg].[idAccount] = @idAccount
    AND [rdgPrg].[idUser] = @idUser
    AND [rdgPrg].[deleted] = 0
  ORDER BY [rdgPrg].[dateRegistered] DESC;
END;
GO

-- ============================================
-- READING GOAL PROCEDURES
-- ============================================

/**
 * @summary
 * Creates a reading goal.
 *
 * @procedure spReadingGoalCreate
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/reading-goal
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {VARCHAR} goalType - Goal type (Livros/Páginas)
 * @param {INT} targetQuantity - Target quantity
 * @param {VARCHAR} period - Period (Mensal/Trimestral/Anual/Personalizado)
 * @param {DATE} startDate - Start date
 * @param {DATE} endDate - End date
 * @param {BIT} notificationsEnabled - Enable notifications
 */
CREATE OR ALTER PROCEDURE [dbo].[spReadingGoalCreate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @goalType VARCHAR(10),
  @targetQuantity INTEGER,
  @period VARCHAR(20),
  @startDate DATE,
  @endDate DATE,
  @notificationsEnabled BIT
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

  /**
   * @validation Goal type validation
   * @throw {goalTypeInvalid}
   */
  IF @goalType IS NULL OR @goalType NOT IN ('Livros', 'Páginas')
  BEGIN
    ;THROW 51000, 'goalTypeInvalid', 1;
  END;

  /**
   * @validation Target quantity validation
   * @throw {targetQuantityInvalid}
   */
  IF @targetQuantity IS NULL OR @targetQuantity < 1
  BEGIN
    ;THROW 51000, 'targetQuantityInvalid', 1;
  END;

  /**
   * @validation Period validation
   * @throw {periodInvalid}
   */
  IF @period IS NULL OR @period NOT IN ('Mensal', 'Trimestral', 'Anual', 'Personalizado')
  BEGIN
    ;THROW 51000, 'periodInvalid', 1;
  END;

  /**
   * @validation Date validation
   * @throw {endDateBeforeStartDate}
   */
  IF @startDate IS NULL OR @endDate IS NULL OR @endDate <= @startDate
  BEGIN
    ;THROW 51000, 'endDateBeforeStartDate', 1;
  END;

  DECLARE @newIdGoal INTEGER;

  BEGIN TRY
    BEGIN TRAN;

    INSERT INTO [dbo].[readingGoal] ([idAccount], [idUser], [goalType], [targetQuantity], [period], [startDate], [endDate], [currentQuantity], [percentComplete], [status], [notificationsEnabled], [dateCreated], [dateModified], [deleted])
    VALUES (@idAccount, @idUser, @goalType, @targetQuantity, @period, @startDate, @endDate, 0, 0, 'Em andamento', @notificationsEnabled, GETUTCDATE(), GETUTCDATE(), 0);

    SET @newIdGoal = SCOPE_IDENTITY();

    /**
     * @output {ReadingGoalCreated, 1, n}
     * @column {INT} idReadingGoal
     * @column {VARCHAR} goalType
     * @column {INT} targetQuantity
     * @column {VARCHAR} period
     * @column {DATE} startDate
     * @column {DATE} endDate
     * @column {VARCHAR} status
     */
    SELECT
      [rdgGl].[idReadingGoal],
      [rdgGl].[goalType],
      [rdgGl].[targetQuantity],
      [rdgGl].[period],
      [rdgGl].[startDate],
      [rdgGl].[endDate],
      [rdgGl].[status]
    FROM [dbo].[readingGoal] [rdgGl]
    WHERE [rdgGl].[idReadingGoal] = @newIdGoal;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO

/**
 * @summary
 * Lists reading goals for a user.
 *
 * @procedure spReadingGoalList
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/reading-goal
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 */
CREATE OR ALTER PROCEDURE [dbo].[spReadingGoalList]
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

  /**
   * @output {ReadingGoalList, n, n}
   * @column {INT} idReadingGoal
   * @column {VARCHAR} goalType
   * @column {INT} targetQuantity
   * @column {VARCHAR} period
   * @column {DATE} startDate
   * @column {DATE} endDate
   * @column {INT} currentQuantity
   * @column {NUMERIC} percentComplete
   * @column {VARCHAR} status
   * @column {BIT} notificationsEnabled
   */
  SELECT
    [rdgGl].[idReadingGoal],
    [rdgGl].[goalType],
    [rdgGl].[targetQuantity],
    [rdgGl].[period],
    [rdgGl].[startDate],
    [rdgGl].[endDate],
    [rdgGl].[currentQuantity],
    [rdgGl].[percentComplete],
    [rdgGl].[status],
    [rdgGl].[notificationsEnabled]
  FROM [dbo].[readingGoal] [rdgGl]
  WHERE [rdgGl].[idAccount] = @idAccount
    AND [rdgGl].[idUser] = @idUser
    AND [rdgGl].[deleted] = 0
  ORDER BY [rdgGl].[startDate] DESC;
END;
GO

/**
 * @summary
 * Gets dashboard statistics for a user.
 *
 * @procedure spDashboardStatisticsGet
 * @schema dbo
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/dashboard/statistics
 *
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier
 * @param {DATE} startDate - Period start date
 * @param {DATE} endDate - Period end date
 */
CREATE OR ALTER PROCEDURE [dbo].[spDashboardStatisticsGet]
  @idAccount INTEGER,
  @idUser INTEGER,
  @startDate DATE,
  @endDate DATE
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

  IF @startDate IS NULL OR @endDate IS NULL
  BEGIN
    ;THROW 51000, 'dateRangeRequired', 1;
  END;

  DECLARE @idBookshelfRead INTEGER;

  SELECT @idBookshelfRead = [bsh].[idBookshelf]
  FROM [dbo].[bookshelf] [bsh]
  WHERE [bsh].[idAccount] = @idAccount
    AND [bsh].[idUser] = @idUser
    AND [bsh].[shelfType] = 'Lido'
    AND [bsh].[deleted] = 0;

  /**
   * @output {DashboardStatistics, 1, n}
   * @column {INT} totalBooksRead
   * @column {INT} totalPagesRead
   * @column {NUMERIC} averageBooksPerMonth
   * @column {NUMERIC} averageRating
   */
  SELECT
    COUNT([bk].[idBook]) AS [totalBooksRead],
    ISNULL(SUM([bk].[pageCount]), 0) AS [totalPagesRead],
    CAST(COUNT([bk].[idBook]) AS NUMERIC(10, 2)) / NULLIF(DATEDIFF(MONTH, @startDate, @endDate) + 1, 0) AS [averageBooksPerMonth],
    ISNULL(AVG([bkRvw].[rating]), 0) AS [averageRating]
  FROM [dbo].[book] [bk]
    LEFT JOIN [dbo].[bookReview] [bkRvw] ON ([bkRvw].[idAccount] = [bk].[idAccount] AND [bkRvw].[idBook] = [bk].[idBook] AND [bkRvw].[deleted] = 0)
  WHERE [bk].[idAccount] = @idAccount
    AND [bk].[idUser] = @idUser
    AND [bk].[idBookshelf] = @idBookshelfRead
    AND [bk].[completionDate] >= @startDate
    AND [bk].[completionDate] <= @endDate
    AND [bk].[deleted] = 0;

  /**
   * @output {TopGenres, n, n}
   * @column {NVARCHAR} genre
   * @column {INT} bookCount
   */
  SELECT TOP 5
    [bk].[genre],
    COUNT([bk].[idBook]) AS [bookCount]
  FROM [dbo].[book] [bk]
  WHERE [bk].[idAccount] = @idAccount
    AND [bk].[idUser] = @idUser
    AND [bk].[idBookshelf] = @idBookshelfRead
    AND [bk].[completionDate] >= @startDate
    AND [bk].[completionDate] <= @endDate
    AND [bk].[genre] IS NOT NULL
    AND [bk].[deleted] = 0
  GROUP BY [bk].[genre]
  ORDER BY COUNT([bk].[idBook]) DESC;

  /**
   * @output {TopAuthors, n, n}
   * @column {NVARCHAR} author
   * @column {INT} bookCount
   */
  SELECT TOP 5
    [bk].[author],
    COUNT([bk].[idBook]) AS [bookCount]
  FROM [dbo].[book] [bk]
  WHERE [bk].[idAccount] = @idAccount
    AND [bk].[idUser] = @idUser
    AND [bk].[idBookshelf] = @idBookshelfRead
    AND [bk].[completionDate] >= @startDate
    AND [bk].[completionDate] <= @endDate
    AND [bk].[deleted] = 0
  GROUP BY [bk].[author]
  ORDER BY COUNT([bk].[idBook]) DESC;
END;
GO