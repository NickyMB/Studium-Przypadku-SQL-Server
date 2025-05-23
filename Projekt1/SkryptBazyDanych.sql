USE [master]
GO
/****** Object:  Database [HMS]    Script Date: 16.05.2025 15:25:49 ******/
CREATE DATABASE [HMS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\HMS.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'HMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\HMS_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [HMS] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [HMS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [HMS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [HMS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [HMS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [HMS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [HMS] SET ARITHABORT OFF 
GO
ALTER DATABASE [HMS] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [HMS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [HMS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [HMS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [HMS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [HMS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [HMS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [HMS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [HMS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [HMS] SET  ENABLE_BROKER 
GO
ALTER DATABASE [HMS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [HMS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [HMS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [HMS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [HMS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [HMS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [HMS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [HMS] SET RECOVERY FULL 
GO
ALTER DATABASE [HMS] SET  MULTI_USER 
GO
ALTER DATABASE [HMS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [HMS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [HMS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [HMS] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [HMS] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [HMS] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'HMS', N'ON'
GO
ALTER DATABASE [HMS] SET QUERY_STORE = ON
GO
ALTER DATABASE [HMS] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [HMS]
GO
/****** Object:  User [Pacjent]    Script Date: 16.05.2025 15:25:49 ******/
CREATE USER [Pacjent] FOR LOGIN [Pacjent] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Lekarz]    Script Date: 16.05.2025 15:25:49 ******/
CREATE USER [Lekarz] FOR LOGIN [Lekarz] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Farmaceuta]    Script Date: 16.05.2025 15:25:49 ******/
CREATE USER [Farmaceuta] FOR LOGIN [Farmaceuta] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [administrator]    Script Date: 16.05.2025 15:25:49 ******/
CREATE USER [administrator] FOR LOGIN [administrator] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [Pacjenci]    Script Date: 16.05.2025 15:25:49 ******/
CREATE ROLE [Pacjenci]
GO
/****** Object:  DatabaseRole [lekarze]    Script Date: 16.05.2025 15:25:49 ******/
CREATE ROLE [lekarze]
GO
/****** Object:  DatabaseRole [Farmaceuci]    Script Date: 16.05.2025 15:25:49 ******/
CREATE ROLE [Farmaceuci]
GO
ALTER ROLE [Pacjenci] ADD MEMBER [Pacjent]
GO
ALTER ROLE [lekarze] ADD MEMBER [Lekarz]
GO
ALTER ROLE [Farmaceuci] ADD MEMBER [Farmaceuta]
GO
ALTER ROLE [db_owner] ADD MEMBER [administrator]
GO
/****** Object:  PartitionFunction [PF_Appointments_ByYear]    Script Date: 16.05.2025 15:25:49 ******/
CREATE PARTITION FUNCTION [PF_Appointments_ByYear](datetime) AS RANGE RIGHT FOR VALUES (N'2023-01-01T00:00:00.000', N'2024-01-01T00:00:00.000', N'2025-01-01T00:00:00.000', N'2026-01-01T00:00:00.000', N'2027-01-01T00:00:00.000')
GO
/****** Object:  PartitionScheme [PF_Appointments]    Script Date: 16.05.2025 15:25:49 ******/
CREATE PARTITION SCHEME [PF_Appointments] AS PARTITION [PF_Appointments_ByYear] TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])
GO
/****** Object:  UserDefinedFunction [dbo].[GetDepartmentID]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[GetDepartmentID](@Name VARCHAR(max))
RETURNS INT
AS
BEGIN
    DECLARE @DepartmentID INT;
    SELECT @DepartmentID = ID FROM Departments WHERE Nazwa = @Name;
    RETURN @DepartmentID;
END
GO
/****** Object:  Table [dbo].[Patients]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patients](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pesel] [char](11) NOT NULL,
	[Imie] [varchar](50) NOT NULL,
	[Nazwisko] [varchar](50) NOT NULL,
	[Adres] [varchar](100) NOT NULL,
	[Telefon] [varchar](15) NULL,
	[DataUrodzenia] [date] NOT NULL,
	[DepartmentsId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Pesel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Appointments]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Appointments](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Data] [datetime] NOT NULL,
	[Diagnoza] [varchar](255) NULL,
	[DoctorsID] [int] NULL,
	[PatientsID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[Data] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PF_Appointments]([Data])
) ON [PF_Appointments]([Data])
GO
/****** Object:  UserDefinedFunction [dbo].[AverageTestPerPatient]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Funkcje
CREATE   FUNCTION [dbo].[AverageTestPerPatient]()
RETURNS TABLE
AS
RETURN
(
  SELECT AVG(AppointmentCount) AS AvgAppointments, CONCAT(SubQuery.Imie,' ',SubQuery.Nazwisko) AS Pacjent
  FROM (
    SELECT COUNT(*) AS AppointmentCount, PatientsID, Patients.Imie, Patients.Nazwisko
    FROM Appointments 
    JOIN Patients ON Appointments.PatientsID = Patients.ID
    GROUP BY PatientsID, Patients.Imie, Patients.Nazwisko
  ) AS SubQuery
  GROUP BY SubQuery.Imie, SubQuery.Nazwisko
);
GO
/****** Object:  Table [dbo].[Doctors]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doctors](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Imie] [varchar](50) NOT NULL,
	[Specjalizacja] [varchar](100) NOT NULL,
	[NrLicencji] [varchar](50) NOT NULL,
	[Telefon] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[NrLicencji] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[MostCommonDoc]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[MostCommonDoc]()
RETURNS TABLE
AS
RETURN
(
    SELECT AVG(AppointmentCount) as AvgAppointments, SubQuery.Imie
    FROM (
        SELECT COUNT(*) as AppointmentCount, DoctorsID, Doctors.Imie
        FROM Appointments JOIN Doctors ON Appointments.DoctorsID = Doctors.ID
        GROUP BY DoctorsID, Doctors.Imie
    ) as SubQuery 
    GROUP BY DoctorsID, SubQuery.Imie 
);
GO
/****** Object:  Table [dbo].[Departments]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nazwa] [varchar](50) NOT NULL,
	[Adres] [varchar](100) NOT NULL,
	[LiczbaLozek] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LabTest]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LabTest](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TypBadania] [varchar](50) NOT NULL,
	[Wynik] [varchar](50) NOT NULL,
	[Data] [datetime] NOT NULL,
	[AppointmentsID] [int] NULL,
	[AppointmentsData] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicalStaff]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalStaff](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pielegniarki_Ilosc] [int] NULL,
	[Laboranci_Ilosc] [int] NULL,
	[TechnicyMedyczni_Ilosc] [int] NULL,
	[DepartmentsID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Medications]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medications](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nazwa] [varchar](50) NOT NULL,
	[Dostepnosc] [int] NOT NULL,
	[Producent] [varchar](100) NOT NULL,
	[TerminWaznosci] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Prescriptions]    Script Date: 16.05.2025 15:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prescriptions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KodLeku] [int] NULL,
	[Dawka] [varchar](50) NOT NULL,
	[Dawkowanie] [varchar](50) NOT NULL,
	[PatientsId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Appointments_Doctors_FK]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_Appointments_Doctors_FK] ON [dbo].[Appointments]
(
	[DoctorsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PF_Appointments]([Data])
GO
/****** Object:  Index [IX_Appointments_Doctors_Patients]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_Appointments_Doctors_Patients] ON [dbo].[Appointments]
(
	[DoctorsID] ASC,
	[PatientsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PF_Appointments]([Data])
GO
/****** Object:  Index [IX_Appointments_Patients_FK]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_Appointments_Patients_FK] ON [dbo].[Appointments]
(
	[PatientsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PF_Appointments]([Data])
GO
/****** Object:  Index [IX_LabTest_Appointments_FK]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_LabTest_Appointments_FK] ON [dbo].[LabTest]
(
	[AppointmentsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MedicalStaff_Departments_FK]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_MedicalStaff_Departments_FK] ON [dbo].[MedicalStaff]
(
	[DepartmentsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Patients_Departments_FK]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_Patients_Departments_FK] ON [dbo].[Patients]
(
	[DepartmentsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Prescriptions_Medications_FK]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_Prescriptions_Medications_FK] ON [dbo].[Prescriptions]
(
	[KodLeku] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Prescriptions_Patients_FK]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_Prescriptions_Patients_FK] ON [dbo].[Prescriptions]
(
	[PatientsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Prescriptions_Patients_Medications]    Script Date: 16.05.2025 15:25:49 ******/
CREATE NONCLUSTERED INDEX [IX_Prescriptions_Patients_Medications] ON [dbo].[Prescriptions]
(
	[PatientsId] ASC,
	[KodLeku] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD FOREIGN KEY([DoctorsID])
REFERENCES [dbo].[Doctors] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD FOREIGN KEY([PatientsID])
REFERENCES [dbo].[Patients] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LabTest]  WITH CHECK ADD FOREIGN KEY([AppointmentsID], [AppointmentsData])
REFERENCES [dbo].[Appointments] ([ID], [Data])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MedicalStaff]  WITH CHECK ADD FOREIGN KEY([DepartmentsID])
REFERENCES [dbo].[Departments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Patients]  WITH CHECK ADD FOREIGN KEY([DepartmentsId])
REFERENCES [dbo].[Departments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prescriptions]  WITH CHECK ADD FOREIGN KEY([KodLeku])
REFERENCES [dbo].[Medications] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prescriptions]  WITH CHECK ADD FOREIGN KEY([PatientsId])
REFERENCES [dbo].[Patients] ([ID])
ON DELETE CASCADE
GO
USE [master]
GO
ALTER DATABASE [HMS] SET  READ_WRITE 
GO
