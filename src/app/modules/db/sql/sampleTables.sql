/****** Object:  Table [dbo].[rel_category_in_relation]    Script Date: 29/09/2018 19:16:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rel_category_in_relation](
	[relationID] [int] NULL,
	[catgoryID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_categories]    Script Date: 29/09/2018 19:16:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_categories](
	[category_id] [int] IDENTITY(1,1) NOT NULL,
	[categoryTitle] [nvarchar](50) NULL,
	[categoryAlias] [nvarchar](50) NULL,
	[categoryValue] [nvarchar](200) NULL,
	[categoryOrderKey] [int] NULL,
 CONSTRAINT [PK_tbl_categories] PRIMARY KEY CLUSTERED 
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_relation]    Script Date: 29/09/2018 19:16:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_relation](
	[relation_id] [int] IDENTITY(1,1) NOT NULL,
	[relationName] [nvarchar](50) NULL,
	[relationBody] [nvarchar](max) NULL,
 CONSTRAINT [PK_tbl_relation] PRIMARY KEY CLUSTERED 
(
	[relation_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_test]    Script Date: 29/09/2018 19:16:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_test](
	[test_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[bool] [bit] NULL,
	[startDate] [datetime] NULL,
	[notes] [nvarchar](max) NULL,
 CONSTRAINT [PK_tbl_test] PRIMARY KEY CLUSTERED 
(
	[test_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
