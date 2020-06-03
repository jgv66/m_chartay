-- use FGR
-- use EFL
-- use FGRHANNA

-- cuales son las baes softland con las que se trabajar�?
-- FGR, EFL y FGRHANNA
-- q: cual es la principal ?
-- En el ordedn en que las puse... OK 


use FGR
go

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> vistas primero
IF ( OBJECT_ID('ARE_PerVig', 'V') IS not NULL ) begin 
	drop view ARE_PerVig ;
end;
go
create view ARE_PerVig as 
SELECT softland.sw_vsnpEstadoPer.Ficha, softland.sw_personal.nombres, softland.sw_vsnpEstadoPer.Estado, softland.sw_personal.fechaIngreso
FROM softland.sw_vsnpEstadoPer 
INNER JOIN softland.sw_personal ON softland.sw_vsnpEstadoPer.Ficha = softland.sw_personal.ficha 
INNER JOIN dbo.ARE_MesesPrep ON softland.sw_vsnpEstadoPer.IndiceMes = dbo.ARE_MesesPrep.Largo;
go
--
IF ( OBJECT_ID('ARE_PersonalActivo', 'V') IS not NULL ) begin 
	drop view ARE_PersonalActivo ;
end;
go
create view ARE_PersonalActivo as 
SELECT	softland.sw_personal.ficha, softland.sw_personal.nombres, softland.sw_personal.rut, softland.sw_personal.FecCalVac AS FCalVac, 
		softland.sw_diasvacanuper.DiasVacAnual, softland.sw_personal.AnoOtraEm, 
        softland.sw_personal.FecCertVacPro, dbo.ARE_CCostoPersActivo.codiCC, dbo.ARE_CCostoPersActivo.DescCC
FROM softland.sw_personal 
INNER JOIN dbo.ARE_PerVig ON softland.sw_personal.ficha = dbo.ARE_PerVig.Ficha 
INNER JOIN softland.sw_diasvacanuper ON dbo.ARE_PerVig.Ficha = softland.sw_diasvacanuper.ficha 
LEFT  JOIN dbo.ARE_CCostoPersActivo ON softland.sw_personal.ficha = dbo.ARE_CCostoPersActivo.ficha
WHERE dbo.ARE_PerVig.Estado = 'V' 
	AND YEAR(softland.sw_diasvacanuper.Vighasta) = 9999;
go
--
IF ( OBJECT_ID('ARE_VacAsig', 'V') IS not NULL ) begin 
	drop view ARE_VacAsig ;
end;
go
create view ARE_VacAsig as 
SELECT Ficha, SUM(NDiasAp) AS Asignadas, MAX(FaDesde) AS Fecha
FROM softland.sw_vacsolic
GROUP BY Ficha;
go
--
IF ( OBJECT_ID('ARE_VacAsigDetalle', 'V') IS not NULL ) begin 
	drop view ARE_VacAsigDetalle ;
end;
go
create view ARE_VacAsigDetalle as 
SELECT	Ficha, CAST(FsDesde AS date) AS sdesde, CAST(FsHasta AS date) AS shasta, 
		Estado, NDias, CAST(FaDesde AS date) AS adesde, 
		CAST(FaHasta AS date) AS ahasta, NDiasAp AS ndiasaplicados
FROM softland.sw_vacsolic;
go
--
IF ( OBJECT_ID('ARE_MesesPrep', 'V') IS not NULL ) begin 
	drop view ARE_MesesPrep ;
end;
go
create view ARE_MesesPrep as 
SELECT MesesPrep, LEN(REPLACE(MesesPrep, '0', '')) AS Largo
FROM softland.swparam;
go
--
IF ( OBJECT_ID('ARE_CCostoPersActivo', 'V') IS not NULL ) begin 
	drop view ARE_CCostoPersActivo ;
end;
go
create view ARE_CCostoPersActivo as 
SELECT softland.sw_ccostoper.ficha, softland.sw_ccostoper.codiCC, softland.cwtccos.DescCC
FROM softland.sw_ccostoper 
INNER JOIN softland.cwtccos ON softland.sw_ccostoper.codiCC = softland.cwtccos.CodiCC
WHERE YEAR(softland.sw_ccostoper.vigHasta) = 9999;
go

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> sp
-- exec ksp_Crear_Tablas ;
IF ( OBJECT_ID('ksp_Crear_Tablas', 'P') IS NOT NULL ) begin
    DROP PROCEDURE ksp_Crear_Tablas;  
end;
GO  
CREATE PROCEDURE ksp_Crear_Tablas
AS
BEGIN
	declare @Error			nvarchar(250), 
			@ErrMsg			nvarchar(2048);
	begin try
		--
		if ( 1=1 ) begin
			--
			CREATE TABLE [dbo].[ktb_io_usuarios] (
				[id] [int] IDENTITY(1,1) NOT NULL,
				[ficha] [char](10) NOT NULL,
				[id_empresa] [int] NOT NULL,
				[ingreso] [datetime] NULL,
				[in_lat] [float] NULL,
				[in_lng] [float] NULL,
				[salida] [datetime] NULL,
				[out_lat] [float] NULL,
				[out_lng] [float] NULL,
				[verificador] [varchar](500) NULL,
			 CONSTRAINT [PK_ktb_io_usuarios] PRIMARY KEY CLUSTERED 
			( [id] ASC ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] ) ON [PRIMARY];
			ALTER TABLE [dbo].[ktb_io_usuarios] ADD  CONSTRAINT [DF_ktb_io_usuarios_id_empresa]  DEFAULT ((1)) FOR [id_empresa];
			ALTER TABLE [dbo].[ktb_io_usuarios] ADD  CONSTRAINT [DF_ktb_io_usuarios_ingreso]  DEFAULT (getdate()) FOR [ingreso];
			--
			if ( @@ERROR <> 0 ) begin
				set @Error  = @@ERROR;
				set @ErrMsg = ERROR_MESSAGE();
				THROW @Error, @ErrMsg, 0 ;  
			end;
			select cast(1 as bit) resultado, cast(0 as bit) error, 'creacion de tabla [ktb_io_usuarios] exitosa' as mensaje 
		end;
		--
		if ( 1=1 ) begin
			--
			CREATE TABLE [dbo].[ktb_multi_usuarios](
				[id] [int] IDENTITY(1,1) NOT NULL,
				[id_empresa] [int] NOT NULL,
				[rut] [varchar](20) NOT NULL,
			 CONSTRAINT [PK_ktb_multi_usuarios] PRIMARY KEY CLUSTERED 
			(
				[id] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY] ;
			--
			if ( @@ERROR <> 0 ) begin
				set @Error  = @@ERROR;
				set @ErrMsg = ERROR_MESSAGE();
				THROW @Error, @ErrMsg, 0 ;  
			end;
			select cast(1 as bit) resultado, cast(0 as bit) error, 'creacion de tabla [ktb_multi_usuarios] exitosa' as mensaje 
		end;
		--
		if ( 1=1 ) begin
			--
			CREATE TABLE [dbo].[ktb_empresas](
				[id_empresa] [int] NOT NULL,
				[rut] [varchar](20) NOT NULL,
				[razonsocial] [varchar](100) NOT NULL,
				[fechacreacion] [char](8) NOT NULL,
				[db] [varchar](30) NOT NULL,
				[usuarios] [int] NOT NULL,
				[llave] [text] NOT NULL,
			 CONSTRAINT [PK_ktb_empresas] PRIMARY KEY CLUSTERED 
			(
				[id_empresa] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
			ALTER TABLE [dbo].[ktb_empresas] ADD  CONSTRAINT [DF_ktb_empresas_db]  DEFAULT ('') FOR [db];
			ALTER TABLE [dbo].[ktb_empresas] ADD  CONSTRAINT [DF_ktb_empresas_usuarios]  DEFAULT ((0)) FOR [usuarios];
			ALTER TABLE [dbo].[ktb_empresas] ADD  CONSTRAINT [DF_ktb_empresas_llave]  DEFAULT ('') FOR [llave];
			--
			if ( @@ERROR <> 0 ) begin
				set @Error  = @@ERROR;
				set @ErrMsg = ERROR_MESSAGE();
				THROW @Error, @ErrMsg, 0 ;  
			end;
			select cast(1 as bit) resultado, cast(0 as bit) error, 'creacion de tabla [ktb_empresas] exitosa' as mensaje 
		end;
		--
		if ( 1=1 ) begin
			--
			CREATE TABLE [dbo].[ktb_solicitudes](
				[id] [int] IDENTITY(1,1) NOT NULL,
				[ficha] [char](10) NULL,
				[tipo] [varchar](20) NULL,
				[dato] [varchar](100) NULL,
				[fecha] [datetime] NULL,
				[cto] [varchar](50) NULL,
				[ccc] [varchar](50) NULL,
				[cerrado] [bit] NOT NULL,
				[fechacierre] [datetime] NULL,
				CONSTRAINT [PK_ktb_solicitudes] PRIMARY KEY CLUSTERED 
			( [id] ASC ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] ) ON [PRIMARY];
			ALTER TABLE [dbo].[ktb_solicitudes] ADD  CONSTRAINT [DF_ktb_solicitudes_cerrado]  DEFAULT ((0)) FOR [cerrado] ;
			--
			if ( @@ERROR <> 0 ) begin
				set @Error  = @@ERROR;
				set @ErrMsg = ERROR_MESSAGE();
				THROW @Error, @ErrMsg, 0 ;  
			end;
			select cast(1 as bit) resultado, cast(0 as bit) error, 'creacion de tabla [ktb_solicitudes] exitosa' as mensaje 
		end;
		--
		if ( 1=1 ) begin
			--
			--drop table [dbo].[ktb_usuarios]
			CREATE TABLE [dbo].[ktb_usuarios](
				[ficha] [char](10) NOT NULL,
				[id_empresa] [int] NOT NULL,
				[rut] [varchar](20) NULL,
				[clave] [varchar](30) NULL,
				[creacion] [datetime] NOT NULL,
				[ultimo_ingreso] [datetime] NOT NULL,
				[supervisor] [bit] NOT NULL DEFAULT 0,
				[cargosuper] varchar(3) null DEFAULT '',
				CONSTRAINT [PK_ktb_usuarios] PRIMARY KEY CLUSTERED 
			( [ficha] ASC ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] ) ON [PRIMARY] ;
			ALTER TABLE [dbo].[ktb_usuarios] ADD  CONSTRAINT [DF_ktb_usuarios_creacion]  DEFAULT (getdate()) FOR [creacion] ;
			ALTER TABLE [dbo].[ktb_usuarios] ADD  CONSTRAINT [DF_ktb_usuarios_ultimo_ingreso]  DEFAULT (getdate()) FOR [ultimo_ingreso] ;
			--
			if ( @@ERROR <> 0 ) begin
				set @Error  = @@ERROR;
				set @ErrMsg = ERROR_MESSAGE();
				THROW @Error, @ErrMsg, 0 ;  
			end;
			select cast(1 as bit) resultado, cast(0 as bit) error, 'creacion de tabla [ktb_usuarios] exitosa' as mensaje 
		end;
		--
		if ( 1=1 ) begin
			--
			CREATE TABLE [dbo].[ktb_documentos_b64](
				[id] [int] IDENTITY(1,1) NOT NULL,
				[codigo] [char](20) NULL,
				[extension] [varchar](10) NULL,
				[nombre] [varchar](50) NULL,
				[base64] [text] NULL,
			 CONSTRAINT [PK_ktb_documentos_b64] PRIMARY KEY CLUSTERED 
			(
				[id] ASC
			) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
			--
			if ( @@ERROR <> 0 ) begin
				set @Error  = @@ERROR;
				set @ErrMsg = ERROR_MESSAGE();
				THROW @Error, @ErrMsg, 0 ;  
			end;
			select cast(1 as bit) resultado, cast(0 as bit) error, 'creacion de tabla [ktb_documentos_b64] exitosa' as mensaje 
		end;
		--
	end try 
	--
	begin catch
		select cast(0 as bit) resultado, cast(1 as bit) error, @ErrMsg as mensaje 
	end catch
END; 
GO

IF OBJECT_ID('kfn_code64', 'FN') IS NOT NULL  
    DROP FUNCTION kfn_code64;  
GO  
CREATE FUNCTION kfn_code64 ( @texto varchar(50) ) 
RETURNS varchar(300)
 with encryption
AS
BEGIN
	--
	declare @coded varchar(max);
	--
	-- Encode the string in Base64
	SELECT @coded =	CAST(N'' AS XML).value( 'xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'VARCHAR(MAX)' )
	FROM ( SELECT CAST( @texto AS VARBINARY(MAX)) AS bin ) AS bin_sql_server_temp;
	--
	return @coded;
end;
go


IF OBJECT_ID('ksp_crearUsuario', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_crearUsuario;  
GO  
CREATE PROCEDURE ksp_crearUsuario (	@rut char(10), @clave varchar(30) ) with encryption
AS 
BEGIN
	begin try
		declare @mirut			varchar(20),
				@ficha			char(10),
				@guionydigito	char(2),
				@tresfondo		char(3),
				@tresmedio		char(3),
				@tresinicio		char(3),
				@keybase64		varchar(300),
				@Error			nvarchar(250), 
				@ErrMsg			nvarchar(2048);

		set @mirut = '000000000' + rtrim(@rut); 

		if ( left(right( @mirut, 2 ),1) <> '-' ) begin
			set @ErrMsg = 'RUT INCORRECTO (Gui�n)';
			THROW @Error, @ErrMsg, 0 ;  
		end
		--
		set @guionydigito = right( @mirut, 2 );
		set @mirut		  = rtrim( replace( @mirut, @guionydigito, ' ' ) );
		-- 
		set @tresfondo  = right( @mirut, 3 )    -- 377
		set @mirut		= rtrim( replace( @mirut, @tresfondo, '' ) );
		--
		set @tresmedio  = right( @mirut, 3 )    -- 565
		set @mirut		= rtrim( replace( @mirut, @tresmedio, '' ) );
		--
		set @tresinicio = right( @mirut, 3 )
		--
		set @mirut = @tresinicio +'.'+ @tresmedio +'.'+ @tresfondo + @guionydigito;
		--
		if exists ( select * from Softland.sw_personal with (nolock) where upper(rut) = upper(@mirut) ) begin
			--
			select @ficha=ficha from Softland.sw_personal with (nolock) where upper(rut) = upper(@mirut);
			if not exists ( select * from ktb_usuarios with (nolock) where ficha=@ficha and rut = @rut ) begin
				--
				-- set @keybase64 = left( dbo.kfn_code64( @clave ),300);
				set @keybase64 = @clave;
				--
				insert into ktb_usuarios (ficha,rut,clave,creacion,ultimo_ingreso) values (@ficha,rtrim(@rut),@keybase64,getdate(),getdate())
				if ( @@ERROR = 0 ) begin
					select cast(1 as bit) resultado, cast(0 as bit) error, 'Usuario fue creado correctamente.' as mensaje 
				end
				else begin
					set @Error  = @@ERROR;
					set @ErrMsg = ERROR_MESSAGE();
					THROW @Error, @ErrMsg, 0 ;  
				end
				--
			end
			else begin
				set @Error  = 0;
				set @ErrMsg = 'Usuario ya existe';
				THROW @Error, @ErrMsg, 0 ;  
			end
		end
		else begin
			select cast(0 as bit) resultado, cast(1 as bit) error, 'Rut no existe: '+@rut as mensaje 
		end

	end try 
	--
	begin catch
		select cast(0 as bit) resultado, cast(1 as bit) error, @ErrMsg as mensaje 
	end catch

END
GO

-- exec ksp_validarUsuario '13704802','123456'
-- exec ksp_validarUsuario '17729998-7', 'Mandala2020' ;
IF OBJECT_ID('ksp_validarUsuario', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_validarUsuario;  
GO  
CREATE PROCEDURE ksp_validarUsuario ( @rut char(10), @clave	varchar(30) )  with encryption
AS
BEGIN

	set nocount on;

	begin try
		declare @ficha		char(10),
				@nombre		varchar(60),
				@email		varchar(100),
				@id_empresa int = -1,
				@Error		nvarchar(250), 
				@ErrMsg		nvarchar(2048);

		-- intento de recuperar la clave
		if ( @clave = '*p3d1r*m1*cl4v3*' ) begin
			--
			if exists ( select * from ktb_usuarios with (nolock) where upper(rut) = upper(@rut) ) begin
				--
				select top 1 
					cast(1 as bit) resultado, cast(0 as bit) error, 
					k.ficha,sf.nombres,sf.rut,
					k.clave as pssw,
					( select top 1 NomB from softland.soempre ) as nombreemp
				from ktb_usuarios as k with (nolock) 
				inner join Softland.sw_personal as sf on sf.ficha=k.ficha
				where upper(k.rut) = upper(@rut);
				--
			end
			else begin
				select cast(0 as bit) resultado, cast(1 as bit) error, 'Rut no existe: '+@rut as mensaje 
			end
		end
		else begin
			--
			if exists ( select * from ktb_usuarios with (nolock) where upper(rut) = upper(@rut) and clave = @clave ) begin
				-- 
				update ktb_usuarios set ultimo_ingreso = getdate() where upper(rut) = upper(@rut) and clave = @clave and creacion<>ultimo_ingreso;
				--
				if @@ERROR<>0 begin
					set @ErrMsg = ERROR_MESSAGE();
					THROW @Error, @ErrMsg, 0 ;  
				end
				--
				select cast(1 as bit) resultado, cast(0 as bit) error, 
					k.ficha,sf.nombre,sf.Email,id_empresa,
					k.supervisor,
					( select top 1 NomB from softland.soempre ) as nombreemp
				from ktb_usuarios as k with (nolock) 
				inner join Softland.sw_personal as sf on sf.ficha=k.ficha
				where upper(k.rut) = upper(@rut)
				and k.clave = @clave;
				--
				-- select cast(1 as bit) resultado, cast(0 as bit) error, @ficha as ficha, @nombre as nombre, @email as email
				--
			end
			else begin
				select cast(0 as bit) resultado, cast(1 as bit) error, 'Rut no existe: '+@rut as mensaje 
			end
		end
		--
	end try 
	--
	begin catch
		select cast(0 as bit) resultado, cast(1 as bit) error, @ErrMsg as mensaje 
	end catch

END
GO

-- EXEC ksp_leerFicha 13704802 ;
IF OBJECT_ID('ksp_leerFicha', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_leerFicha;  
GO  
CREATE PROCEDURE ksp_leerFicha (
	@ficha	char(10)
)  with encryption
AS
BEGIN
	--
	set nocount on ;
	--
	SELECT sw.ficha as codigo
		  ,sw.nombres
		  ,sw.rut
		  ,sw.direccion
		  ,sw.codComuna
		  ,( select top 1 NomComuna FROM softland.socomunas as co with (nolock) where co.CodComuna=sw.codComuna ) as nomcomuna
		  ,sw.codCiudad
		  ,( select top 1 NomCiudad FROM softland.sociudades as ci with (nolock) where ci.CodCiudad=sw.codCiudad ) as nomciudad
		  ,sw.telefono1
		  ,sw.telefono2
		  ,sw.fechaNacimient
		  ,sw.sexo
		  ,sw.estadoCivil
		  ,sw.nacionalidad
		  ,sw.fechaIngreso
		  ,sw.fechaContratoV
		  ,sw.appaterno
		  ,sw.apmaterno
		  ,sw.nombre
		  ,sw.Email as email
		  ,(case	when sw.estadoCivil = 'S' then 'Solter'+(case when sw.sexo='F' then 'a' else 'o' end  )
					when sw.estadoCivil = 'C' then 'Casad'+(case when sw.sexo='F' then 'a' else 'o' end  )
					else '???' 
			end) as estadocivil
		  ,sw.numCargasSimp
		  ,sw.numCargasInval
		  ,sw.numCargasMater
		  ,(select boss.nombres from softland.sw_personal as boss with (nolock) where sw.JefeDirecto=boss.ficha  ) as jefedirecto
		  ,sw.fechaContratoV as fechacontrato
		  ,(select top 1 RutE from softland.soempre ) as [mi_empresa_rut] 
		  ,(select top 1 NomB from softland.soempre ) as [mi_empresa_rs] 
		  ,(select top 1 Giro from softland.soempre ) as [mi_empresa_giro] 
		  ,(select top 1 rtrim(ltrim(Dire))+' - '+rtrim(ltrim(Provi))+' - '+rtrim(ltrim(Comu)) from softland.soempre ) as [mi_empresa_dire] 
		  ,(select top 1 Fono from softland.soempre ) as [mi_empresa_fono] 
	  FROM [softland].[sw_personal] as sw with (nolock)
	  where ficha = @ficha;
	  --
END
go

-- exec ksp_guardaSolicitud '321654','anticipo','anticipo : 50000','jogv66@gmail.com',null, 1 ;
IF OBJECT_ID('ksp_guardaSolicitud', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_guardaSolicitud;  
GO  
CREATE PROCEDURE ksp_guardaSolicitud
	@ficha	 char(10), 
	@tipo	 varchar(20),
	@dato	 varchar(100),
	@cto	 varchar(50),
	@ccc	 varchar(50)='',
	@cerrado bit = 0 
with encryption
AS
BEGIN
	begin try
		declare @Error	 nvarchar(250), 
				@ErrMsg	 nvarchar(2048);
		--
		insert into ktb_solicitudes (ficha, tipo,        dato,        fecha,    cto, ccc, cerrado, fechacierre) 
							 values (@ficha,rtrim(@tipo),rtrim(@dato),getdate(),@cto,@ccc,@cerrado,(case when @cerrado = 1 then getdate() else null end) )
		if ( @@ERROR = 0 ) begin
			select cast(1 as bit) resultado, cast(0 as bit) error, 'solicitud creada correctamente.' as mensaje 
		end
		else begin
			set @Error  = @@ERROR;
			set @ErrMsg = ERROR_MESSAGE();
			THROW @Error, @ErrMsg, 0 ;  
		end

	end try 
	--
	begin catch
		select cast(0 as bit) resultado, cast(1 as bit) error, @ErrMsg as mensaje 
	end catch

END
GO

-- exec ksp_guardaGeoPos '17729998',1,'S',-70.5560576,-33.4168064 ;
IF OBJECT_ID('ksp_guardaGeoPos', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_guardaGeoPos;  
GO  
CREATE PROCEDURE ksp_guardaGeoPos
	@ficha	 char(10), 
	@empresa int,
	@io		 char(1),   /* F=followme, I=ingreso, S=salida */
	@lat	 varchar(100),
	@lng	 varchar(50) 
with encryption
AS
BEGIN
	begin try
		declare @id		 int,
				@Error	 nvarchar(250), 
				@ErrMsg	 nvarchar(2048);
		--
		if ( @io in ('F','I') ) begin
			insert into ktb_io_usuarios (ficha, id_empresa,ingreso, in_lat, in_lng ) values (@ficha, @empresa, getdate(), @lat, @lng );
			--
			if ( @@ERROR <> 0 ) begin
				set @Error  = @@ERROR;
				set @ErrMsg = ERROR_MESSAGE();
				THROW @Error, @ErrMsg, 0 ;  
			end;
			--
			select cast(1 as bit) resultado, cast(0 as bit) error, 'Ingreso registrado con �xito.' as mensaje ;
			--
		end;
		if ( @io in ('S') ) begin
			-- si es una salida normal
			if exists ( select * from ktb_io_usuarios where ficha=@ficha and cast(ingreso as date) = cast( getdate() as date ) and id_empresa = @empresa ) begin
				--
				select top 1 @id = id from ktb_io_usuarios where ficha=@ficha and cast(ingreso as date) = cast( getdate() as date ) and id_empresa = @empresa;
				--
				update ktb_io_usuarios set salida = getdate(), out_lat = @lat, out_lng = @lng where id = @id ;
				--
				if ( @@ERROR <> 0 ) begin
					set @Error  = @@ERROR;
					set @ErrMsg = ERROR_MESSAGE();
					THROW @Error, @ErrMsg, 0 ;  
				end;
				--
				select cast(1 as bit) resultado, cast(0 as bit) error, 'Salida registrada con �xito.' as mensaje ;
				--
			end 
			-- si es una salida sin ingreso o que no corresponde a la misma fecha
			else begin
				insert into ktb_io_usuarios (ficha, id_empresa,salida, out_lat, out_lng ) values (@ficha, @empresa, getdate(),@lat, @lng );
				--
				if ( @@ERROR <> 0 ) begin
					set @Error  = @@ERROR;
					set @ErrMsg = ERROR_MESSAGE();
					THROW @Error, @ErrMsg, 0 ;  
				end;
				--
				select cast(1 as bit) resultado, cast(0 as bit) error, 'Salida registrada con �xito.' as mensaje 
				--
			end
			--
		end;
		--
	end try 
	--
	begin catch
		select cast(0 as bit) resultado, cast(1 as bit) error, @ErrMsg as mensaje 
	end catch
	--
END
GO

-- exec ksp_leerMisAsistencias '10594206' ;
IF OBJECT_ID('ksp_leerMisAsistencias', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_leerMisAsistencias;  
GO  
CREATE PROCEDURE ksp_leerMisAsistencias
	@ficha	char(10)
 with encryption
AS
BEGIN
	--
	select id,ficha,ingreso,in_lat,in_lng,salida,out_lat,out_lng
			,convert( nvarchar(10),ingreso,103) as fechain, CONVERT(CHAR(5), ingreso, 108) AS horain
			,convert( nvarchar(10),salida,103) as fechaout, CONVERT(CHAR(5), salida, 108) AS horaout
	from ktb_io_usuarios with (nolock)
	where ficha = @ficha
	order by id desc
	--
END
GO

-- exec ksp_leerMisMensajes '17729998' ;
IF OBJECT_ID('ksp_leerMisMensajes', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_leerMisMensajes;  
GO  
CREATE PROCEDURE ksp_leerMisMensajes
	@ficha	char(10)
 with encryption
AS
BEGIN
	--
	select id,ficha,tipo,rtrim(dato) as dato,cast(fecha as date) as fecha,rtrim(cto) as cto,rtrim(ccc) as ccc,cerrado,fechacierre 
	from ktb_solicitudes with (nolock)
	where ficha = @ficha
	order by cerrado,fecha desc
	--
END
GO

-- exec ksp_cerrarMensaje 1 ;
IF OBJECT_ID('ksp_cerrarMensaje', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_cerrarMensaje;  
GO  
CREATE PROCEDURE ksp_cerrarMensaje
	@id	char(10)
 with encryption
AS
BEGIN
	--
	update ktb_solicitudes set cerrado=1,fechacierre=getdate() where id = @id ;
	select cast(1 as bit) as resultado;
	--
END
GO

-- exec ksp_leerMisLiquidaciones '17729998' ;
IF OBJECT_ID('ksp_leerMisLiquidaciones', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_leerMisLiquidaciones;  
GO  
CREATE PROCEDURE ksp_leerMisLiquidaciones
	@ficha	char(10)
 with encryption
AS
BEGIN
	--
	SELECT (case substring(convert(varchar(11),Fecha,113),4,3)
        	 when 'ENE' then 'Enero'
			 when 'JAN' then 'Enero'
	         when 'FEB' then 'Febrero'
	         when 'MAR' then 'Marzo'
	         when 'ABR' then 'Abril'
	         when 'APR' then 'Abril'
	         when 'MAY' then 'Mayo'
	         when 'JUN' then 'Junio'
	         when 'JUL' then 'Julio'
	         when 'AGO' then 'Agosto'
			 when 'AUG' then 'Agosto'
	         when 'SEP' then 'Septiembre'
	         when 'OCT' then 'Octubre'
	         when 'NOV' then 'Noviembre'
	         when 'DIC' then 'Diciembre'
			 when 'DEC' then 'Diciembre'
			end) + ' - ' + substring(convert(varchar(11),Fecha,113),8,4) as periodo,
			substring(convert(varchar(11),Fecha,113),4,3)+cast( year(Fecha) as char(4)) as filename,
			Id_Archivo as id_pdf,
			cast( 0 as bit ) as descargando
	FROM [softland].[sw_archivosmesper] with (nolock)
	where ficha=@ficha 
	order by fecha desc 
	--
END
GO

-- exec ksp_get1base64 'CERT_ANTIG' ;
IF OBJECT_ID('ksp_get1base64', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_get1base64;  
GO  
CREATE PROCEDURE ksp_get1base64
	@id_pdf	int
 with encryption
AS
BEGIN
	--
	select ArchivoBase64 as pdfbase64
	from [softland].[Sw_Archivos] with (nolock)
	where Id_Archivo = @id_pdf
	--
END;
GO

IF OBJECT_ID('ksp_getRegiones', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_getRegiones;  
GO  
CREATE PROCEDURE ksp_getRegiones 
with encryption
AS
BEGIN
	--
	select distinct CodRegion as cod
					,NomRegion as nom 
	FROM softland.soregiones with (nolock)
	where CodPais='CL' 
	order by cod ;
	--
END;
GO

IF OBJECT_ID('ksp_getCiudades', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_getCiudades ;  
GO  
CREATE PROCEDURE ksp_getCiudades 
	@region varchar(10)
with encryption
AS
BEGIN
	--
	select	CodCiudad as cod
			,NomCiudad as nom 
	FROM softland.sociudades with (nolock)
	where CodPais='CL' 
	  and CodRegion = @region
	order by nom ;
	--
END;
GO

IF OBJECT_ID('ksp_getComunas', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_getComunas ;  
GO  
CREATE PROCEDURE ksp_getComunas 
	@region varchar(10)
with encryption
AS
BEGIN
	--
	select	CodComuna as cod
			,NomComuna as nom 
	FROM softland.socomunas as co with (nolock)
	where co.CodRegion= @region
	  and co.CodPais='CL' 
	order by nom ; 
	--
END;
GO

IF OBJECT_ID('ksp_getIsapres', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_getIsapres ;  
GO  
CREATE PROCEDURE ksp_getIsapres 
with encryption
AS
BEGIN
	--
	select nombre as nom FROM softland.sw_isapre with (nolock)
    union
    select 'Fonasa' as nom
    order by nom ; 
	--
END;
GO

IF OBJECT_ID('ksp_getAfps', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_getAfps ;  
GO  
CREATE PROCEDURE ksp_getAfps 
with encryption
AS
BEGIN
	--
	select nombre as nom 
	FROM softland.sw_afp with (nolock)
	order by nom ; 
	--
END;
GO

IF OBJECT_ID('kfn_getMes', 'FN') IS NOT NULL  
    DROP FUNCTION kfn_getMes;  
go
CREATE FUNCTION [dbo].kfn_getMes ( @numeroMes int )
RETURNS varchar(20)
 with encryption
AS
begin
	declare @mes varchar(20) = '';
	set @mes = (case 
					when @numeroMes = 1  then 'enero' 
					when @numeroMes = 2  then 'febrero'
					when @numeroMes = 3  then 'marzo'
					when @numeroMes = 4  then 'abril'
					when @numeroMes = 5  then 'mayo'
					when @numeroMes = 6  then 'junio' 
					when @numeroMes = 7  then 'julio' 
					when @numeroMes = 8  then 'agosto' 
					when @numeroMes = 9  then 'septiembre' 
					when @numeroMes = 10 then 'octubre' 
					when @numeroMes = 11 then 'noviembre' 
					when @numeroMes = 12 then 'diciembre'
					else '???'
				end); 
	return @mes;
end;
go 

IF OBJECT_ID('ksp_get1base64Cert', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_get1base64Cert;  
GO  
CREATE PROCEDURE ksp_get1base64Cert
	@key char(20),
	@ficha varchar(10)
 with encryption
AS
BEGIN
	--
	with cargo 
	as (SELECT TOP 1 per.carCod,ca.CarNom as cargo
		FROM [softland].[sw_cargoper] as per
		left join softland.cwtcarg as ca on ca.CarCod=per.carCod
		where per.ficha = @ficha )
	select	nombres,rut,
			cast(day(sw.fechaContratoV) as char(2)) +' de '+ dbo.kfn_getMes( month( sw.fechaContratoV ) ) +' de '+ cast( year(sw.fechaContratoV) as char(4) ) as fechaingreso,
			cargo.cargo as labor, 
			day(getdate()) as dia_hoy, dbo.kfn_getMes( month( getdate() ) ) as mes_hoy, year(getdate()) as anno_hoy,
			b64.extension,b64.base64 as archivo
	from dbo.ktb_documentos_b64 as b64, [softland].[sw_personal] as sw, cargo
	where b64.codigo = @key
	  and sw.ficha = @ficha 
	--
END;
GO

IF OBJECT_ID('kfn_diasProgresivos', 'FN') IS NOT NULL  
    DROP FUNCTION kfn_diasProgresivos;  
GO
CREATE FUNCTION [dbo].[kfn_diasProgresivos] ( @anno as int, @acumulado bit )
RETURNS int
WITH ENCRYPTION
AS
BEGIN 

	declare @dias int = 0,
			@diasp int = 0,
			@diaspacum int = 0 ;
	--
	if ( @anno between 0 and 12 )	begin set @diasp = 0 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 13 )				begin set @diasp = 1 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 14 )				begin set @diasp = 1 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 15 )				begin set @diasp = 1 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 16 )				begin set @diasp = 2 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 17 )				begin set @diasp = 2 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 18 )				begin set @diasp = 2 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 19 )				begin set @diasp = 3 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 20 )				begin set @diasp = 3 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 21 )				begin set @diasp = 3 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 22 )				begin set @diasp = 4 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 23 )				begin set @diasp = 4 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 24 )				begin set @diasp = 4 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 25 )				begin set @diasp = 5 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 26 )				begin set @diasp = 5 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 27 )				begin set @diasp = 5 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 28 )				begin set @diasp = 6 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 29 )				begin set @diasp = 6 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 30 )				begin set @diasp = 6 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 31 )				begin set @diasp = 7 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 32 )				begin set @diasp = 7 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 33 )				begin set @diasp = 7 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 34 )				begin set @diasp = 8 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 35 )				begin set @diasp = 8 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 36 )				begin set @diasp = 8 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 37 )				begin set @diasp = 9 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 38 )				begin set @diasp = 9 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 39 )				begin set @diasp = 9 ; set @diaspacum += @diasp;	end;
	if ( @anno >= 40 )				begin set @diasp = 10; set @diaspacum += @diasp;	end;
	if ( @anno >= 41 )				begin set @diasp = 10; set @diaspacum += @diasp;	end;
	if ( @anno >= 42 )				begin set @diasp = 10; set @diaspacum += @diasp;	end;
	if ( @anno >= 43 )				begin set @diasp = 11; set @diaspacum += @diasp;	end;
	if ( @anno >= 44 )				begin set @diasp = 11; set @diaspacum += @diasp;	end;
	if ( @anno >= 45 )				begin set @diasp = 11; set @diaspacum += @diasp;	end;
	if ( @anno >= 46 )				begin set @diasp = 12; set @diaspacum += @diasp;	end;
	if ( @anno >= 47 )				begin set @diasp = 12; set @diaspacum += @diasp;	end;
	if ( @anno >= 48 )				begin set @diasp = 12; set @diaspacum += @diasp;	end;
	if ( @anno >= 49 )				begin set @diasp = 13; set @diaspacum += @diasp;	end;
	if ( @anno >= 50 )				begin set @diasp = 13; set @diaspacum += @diasp;	end;
	if ( @anno >= 51 )				begin set @diasp = 13; set @diaspacum += @diasp;	end;
	if ( @anno >= 52 )				begin set @diasp = 14; set @diaspacum += @diasp;	end;
	if ( @anno >= 53 )				begin set @diasp = 14; set @diaspacum += @diasp;	end;
	if ( @anno >= 54 )				begin set @diasp = 14; set @diaspacum += @diasp;	end;
	if ( @anno >= 55 )				begin set @diasp = 15; set @diaspacum += @diasp;	end;
	if ( @anno >= 56 )				begin set @diasp = 15; set @diaspacum += @diasp;	end;
	if ( @anno >= 57 )				begin set @diasp = 15; set @diaspacum += @diasp;	end;
	if ( @anno >= 58 )				begin set @diasp = 16; set @diaspacum += @diasp;	end;
	if ( @anno >= 59 )				begin set @diasp = 16; set @diaspacum += @diasp;	end;
	if ( @anno >= 60 )				begin set @diasp = 16; set @diaspacum += @diasp;	end;
	--
	if ( @acumulado = 1 )
		set @dias = @diaspacum;
	else
		set @dias = @diasp;
	--
	return @dias;
END;
GO

-- exec ksp_vacaciones '17729998'
IF OBJECT_ID('ksp_vacaciones', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_vacaciones;  
GO  
CREATE PROCEDURE ksp_vacaciones ( @ficha varchar(10) ) With Encryption
AS
BEGIN
	--
    SET NOCOUNT ON;
	--
	declare @nombres varchar(60),
			@rut varchar(20),
			@fcalvac date,
			@diasvacanual int,
			@anootraem int,
			@feccertvacpro date,
			@codicc varchar(8),
			@desccc varchar(60);
	-- c�lculos
	declare @legalesperant decimal(18,5) = 0.0,
			@legalsin15	decimal(18,5) = 0.0,
			@progresivasperant decimal(18,5) = 0.0,
			@progresivasperact decimal(18,5) = 0.0,
			@calculomeses decimal(18,5) = 0.0,
			@fechacallegact date,
			@nfeccallegact decimal(18,5) = 0.0,
			@legalesperact as decimal(18,3) = 0.0,
			@adicionales decimal(18,5) = 0.0,
			@diacalvac char(2),
			@meshoy char(2),
			@annohoy char(4),
			@total decimal(18,5) = 0.0,
			@asignadas decimal(18,5) = 0.0,
			@totaldisponible decimal(18,5) = 0.0;
	declare @fechahoy date = getdate();
	--
	begin try
	--		
		select	@nombres=nombres,@rut=rut,@fcalvac=FCalVac,@diasvacanual=cast(coalesce(DiasVacAnual,0) as decimal(18,5)),
				@anootraem=coalesce(AnoOtraEm,0),@feccertvacpro=FecCertVacPro,@codicc=codiCC,@desccc=DescCC  
		from ARE_PersonalActivo 
		where ficha = @ficha ;
		--
		select @legalsin15 = DATEDIFF(yy,@fcalvac,@fechahoy) - 1;
		-- legales
		if ( @legalesperant = 1 and DATEDIFF(dd,@fcalvac,@fechahoy)<364 ) begin
			set @legalesperant = 0;
		end
		else begin
			set @legalesperant = @legalsin15 * 15;
		end
		-- progresivas
		if ( (@legalsin15 + (case when @anootraem=0 then 0 else @anootraem - 1 end) )>12 ) begin
			set @progresivasperant = dbo.kfn_diasProgresivos( (@legalsin15 + (case when @anootraem=0 then 0 else @anootraem - 1 end) ), 1 ) ;
		end
		else begin
			set @progresivasperant = 0;
		end;
		-- c�lculo mes
		set @calculomeses = cast(month(@fechahoy) as int) - cast( month(@fcalvac) as int );
		if ( @calculomeses<=0 ) begin
			set @calculomeses += 12;
		end
		-- Fecha Calculo Legal Actual
		set @diacalvac		= case when    day(@fcalvac)<10 then '0'+cast(    day(@fcalvac) as char(1) ) else cast(    day(@fcalvac) as char(2) ) end;
		set @meshoy			= case when month(@fechahoy)<10 then '0'+cast( month(@fechahoy) as char(1) ) else cast( month(@fechahoy) as char(2) ) end;
		set @annohoy		= cast( year(@fechahoy) as char(4) );
		set @fechacallegact	= cast( concat( @annohoy, @meshoy, @diacalvac) as date );
		set @nfeccallegact	= datediff( dd, @fechacallegact, @fechahoy );
		if ( @nfeccallegact < 0 ) begin
			set @nfeccallegact += 12;
		end
		-- exec ksp_vacaciones '05430541' ;
		set @legalesperact = ((@calculomeses*(cast(@diasvacanual as decimal(18,5))/12))) + (@nfeccallegact*(15/12)/30) + ((@progresivasperact/12)*@calculomeses) + @nfeccallegact*((@progresivasperact/12)/30);
		--
		set @progresivasperact = 0;
		--
		set @adicionales = 0;
		--
		set @total = @legalesperant + @progresivasperant + @legalesperact + @adicionales ;
		-- asignadas
		select @asignadas = Asignadas 
		from dbo.ARE_VacAsig 
		where Ficha=@ficha;
		--
		if ( @asignadas is null ) begin
			set @asignadas = 0;
		end
		-- total disponible
		set @totaldisponible = @total - @asignadas;
		--
		select	nombres,rut,FCalVac as fcalvac,DiasVacAnual as diasvacanual,AnoOtraEm as anootraem,FecCertVacPro as feccertvacpro,codiCC as codicc,DescCC as desccc,
				@fechahoy as fechahoy,
				@legalesperant as legalesperant,
				@progresivasperant as progresivasperant,
				@calculomeses as calculomeses,
				@nfeccallegact as nfechacallegact,
				@legalesperact as legalesperact,
				@adicionales as adicionales,
				@total as [total],
				@asignadas as asignadas,
				@totaldisponible as totaldisponible
		from ARE_PersonalActivo 
		where ficha = @ficha ;
		--
	end try
	begin catch
		-- select nada
	end catch
end;
go

-- exec ksp_detalle_Vacaciones '17729998' ;
IF OBJECT_ID('ksp_detalle_Vacaciones', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_detalle_Vacaciones;  
GO 
CREATE PROCEDURE ksp_detalle_Vacaciones ( @ficha char(10) ) with encryption
AS
BEGIN
	--
	set nocount on
	--
	select * from ARE_VacAsigDetalle  
	where ficha = @ficha
	order by adesde desc ;
	--
END;
GO

-- exec ksp_licencMedic '17729998' ;
IF OBJECT_ID('ksp_licencMedic', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_licencMedic;  
GO 
CREATE PROCEDURE ksp_licencMedic
	@ficha	char(10)
 with encryption
AS
BEGIN
	--
	select Ficha as ficha,Electronica as electronica,FechaIniRep as inicio,FechaTermino as final,NroDiasLic as dias,[Observacion] as obs
	from softland.sw_lmlicmedlog with (nolock)
	where ficha = @ficha
	order by inicio desc;
	--
END;
GO

-- exec ksp_dameEmpresa '17729998-7' --> 1 ;
-- exec ksp_dameEmpresa '*todos*' --> 3 ;
IF OBJECT_ID('ksp_dameEmpresa', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_dameEmpresa;  
GO 
CREATE PROCEDURE ksp_dameEmpresa ( @rut varchar(20) ) with encryption
AS 
BEGIN
	--
	set nocount on 
	--
	if ( @rut = '*todos*' ) begin
		select id_empresa,upper(rut) as rut
		from ktb_multi_usuarios with (nolock) 
		order by rut;
	end
	else begin
		select id_empresa
		from ktb_multi_usuarios with (nolock) 
		where rut = @rut ;
	end;
	--
end;
go

-- exec ksp_cambiarPass '17729998-7','Mandala2020','2020Mandala' ;
IF OBJECT_ID('ksp_cambiarPass', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_cambiarPass;  
GO 
CREATE PROCEDURE ksp_cambiarPass ( @rut varchar(20), @claveactual varchar(50), @nuevaclave varchar(50) ) with encryption
AS 
BEGIN
	--
	set nocount on 
	--
	if exists ( select * from  ktb_usuarios with (nolock) where upper(rut) = upper(@rut) and clave = @claveactual ) begin
		--
		update ktb_usuarios set clave = @nuevaclave, ultimo_ingreso = getdate() where upper(rut) = upper(@rut) and clave = @claveactual
		--
		select cast(1 as bit) resultado, cast(0 as bit) error, 'Cambio de clave exitoso.' as mensaje 
	end
	else begin
		select cast(0 as bit) resultado, cast(1 as bit) error, 'Usuario/Clave no existe. Corrija y reintente.' as mensaje 
	end;
	--
end;
go


/*
ESTE SP DEBE LLENARSE EL ID_EMPRESA CON EL que CORRESPONDA 1,2,3,ETC
DEBE EJECUTARSE COMO JOB trasladando los nuevos usuarios a las tablas de usuarios mandala.
periodicidad: 1 � 2 veces al dia antes que "ksp_llena_multi_usuarios;"
*/
-- truncate table ktb_usuarios
-- exec ksp_llena_usuarios;
IF OBJECT_ID('ksp_llena_usuarios', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_llena_usuarios;  
GO 
CREATE PROCEDURE ksp_llena_usuarios
with encryption
AS
BEGIN
	--
	insert into ktb_usuarios (id_empresa,ficha,rut,clave,creacion)
	SELECT 2, -- id de la empresa 1=principal
		   ficha,cast(cast(replace(substring(rut,1,11),'.','') as int) as varchar(12))+ right( rtrim(rut),2 ),
		   left(cast(cast(replace(substring(rut,1,11),'.','') as int) as varchar(12)),4),
		   getdate()
	  FROM [softland].[sw_personal] as sw with (nolock)
	  where ( FecTermContrato is null or FecTermContrato > cast( getdate() as date ) )
	    and ISNUMERIC(ficha)=1
		and not exists ( select * from ktb_usuarios as u where u.ficha = sw.ficha )
	--
end;
go

/* 
ESTE SP DEBE EJECUTARSE COMO JOB trasladando los nuevos usuarios mandala a la tabla de 
concurrecia en donde estan todos los usuarios de todas las empresas.
periodicidad: 1 � 2 veces al dia
*/
-- truncate table ktb_multi_usuarios
-- exec ksp_llena_multi_usuarios;
IF OBJECT_ID('ksp_llena_multi_usuarios', 'P') IS NOT NULL  
    DROP PROCEDURE ksp_llena_multi_usuarios;  
GO 
CREATE PROCEDURE ksp_llena_multi_usuarios
with encryption
AS
BEGIN
	-- primera empresa
	insert into ktb_multi_usuarios (id_empresa,rut)
	SELECT id_empresa,rut
	FROM ktb_usuarios as sw with (nolock)
	where not exists ( select * from ktb_multi_usuarios as u where u.rut = sw.rut and u.id_empresa=sw.id_empresa )
	-- segunda empresa
	insert into ktb_multi_usuarios (id_empresa,rut)
	SELECT id_empresa,rut
    FROM [EFL].[dbo].ktb_usuarios as sw with (nolock)
	where not exists ( select * from ktb_multi_usuarios as u where u.rut = sw.rut and u.id_empresa=sw.id_empresa )
	-- tercera empresa
	insert into ktb_multi_usuarios (id_empresa,rut)
	SELECT id_empresa,rut
    FROM [FGRHANNA].[dbo].ktb_usuarios as sw with (nolock)
	where not exists ( select * from ktb_multi_usuarios as u where u.rut = sw.rut and u.id_empresa=sw.id_empresa )
	--
end;
go

-- creacion de los cerificados: en esto se debe trabajar para dejar estos en cada empresa
if not exists ( select * from ktb_documentos_b64 where codigo='CERT-ANTIG' ) begin
	insert into ktb_documentos_b64 (codigo,extension,nombre,base64) 
	values ('CERT-ANTIG','HTML','Certificado de Antiguedad','PGh0bWw+DQoNCjxoZWFkPg0KICAgIDxtZXRhIGh0dHAtZXF1aXY9IkNvbnRlbnQtVHlwZSIgY29udGVudD0idGV4dC9odG1sOyBjaGFyc2V0PXV0Zi04IiAvPg0KICAgIDxtZXRhIG5hbWU9InZpZXdwb3J0IiBjb250ZW50PSJ3aWR0aD1kZXZpY2Utd2lkdGgiIC8+DQogICAgPHN0eWxlIHR5cGU9InRleHQvY3NzIj4NCiAgICAgICAgKiB7DQogICAgICAgICAgICBtYXJnaW46IDA7DQogICAgICAgICAgICBwYWRkaW5nOiAwOw0KICAgICAgICAgICAgZm9udC1zaXplOiAxMDAlOw0KICAgICAgICAgICAgZm9udC1mYW1pbHk6ICdBdmVuaXIgTmV4dCcsICJIZWx2ZXRpY2EgTmV1ZSIsICJIZWx2ZXRpY2EiLCBIZWx2ZXRpY2EsIEFyaWFsLCBzYW5zLXNlcmlmOw0KICAgICAgICAgICAgbGluZS1oZWlnaHQ6IDEuNjU7DQogICAgICAgIH0NCiAgICAgICAgDQogICAgICAgIGJvZHksDQogICAgICAgIC5ib2R5LXdyYXAgew0KICAgICAgICAgICAgd2lkdGg6IDEwMCUgIWltcG9ydGFudDsNCiAgICAgICAgICAgIGhlaWdodDogMTAwJTsNCiAgICAgICAgICAgIGJhY2tncm91bmQ6ICNlZmVmZWY7DQogICAgICAgICAgICAtd2Via2l0LWZvbnQtc21vb3RoaW5nOiBhbnRpYWxpYXNlZDsNCiAgICAgICAgICAgIC13ZWJraXQtdGV4dC1zaXplLWFkanVzdDogbm9uZTsNCiAgICAgICAgfQ0KICAgICAgICANCiAgICAgICAgLnRleHQtY2VudGVyIHsNCiAgICAgICAgICAgIHRleHQtYWxpZ246IGNlbnRlcjsNCiAgICAgICAgfQ0KICAgICAgICANCiAgICAgICAgLnRleHQtcmlnaHQgew0KICAgICAgICAgICAgdGV4dC1hbGlnbjogcmlnaHQ7DQogICAgICAgIH0NCiAgICAgICAgDQogICAgICAgIC50ZXh0LWxlZnQgew0KICAgICAgICAgICAgdGV4dC1hbGlnbjogbGVmdDsNCiAgICAgICAgfQ0KICAgICAgICANCiAgICAgICAgaDEsDQogICAgICAgIGgyLA0KICAgICAgICBoMywNCiAgICAgICAgaDQsDQogICAgICAgIGg1LA0KICAgICAgICBoNiB7DQogICAgICAgICAgICBtYXJnaW4tYm90dG9tOiAyMHB4Ow0KICAgICAgICAgICAgbGluZS1oZWlnaHQ6IDEuMjU7DQogICAgICAgIH0NCiAgICAgICAgDQogICAgICAgIGgxIHsNCiAgICAgICAgICAgIGZvbnQtc2l6ZTogMzJweDsNCiAgICAgICAgfQ0KICAgICAgICANCiAgICAgICAgaDIgew0KICAgICAgICAgICAgZm9udC1zaXplOiAyOHB4Ow0KICAgICAgICB9DQogICAgICAgIA0KICAgICAgICBoMyB7DQogICAgICAgICAgICBmb250LXNpemU6IDI0cHg7DQogICAgICAgIH0NCiAgICAgICAgDQogICAgICAgIGg0IHsNCiAgICAgICAgICAgIGZvbnQtc2l6ZTogMjBweDsNCiAgICAgICAgfQ0KICAgICAgICANCiAgICAgICAgaDUgew0KICAgICAgICAgICAgZm9udC1zaXplOiAxNnB4Ow0KICAgICAgICB9DQogICAgICAgIA0KICAgICAgICBwLA0KICAgICAgICB1bCwNCiAgICAgICAgb2wgew0KICAgICAgICAgICAgZm9udC1zaXplOiAxNnB4Ow0KICAgICAgICAgICAgZm9udC13ZWlnaHQ6IG5vcm1hbDsNCiAgICAgICAgICAgIG1hcmdpbi1ib3R0b206IDIwcHg7DQogICAgICAgIH0NCiAgICAgICAgDQogICAgICAgIC5jb250YWluZXIgew0KICAgICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogd2hpdGU7DQogICAgICAgICAgICBkaXNwbGF5OiBibG9jayAhaW1wb3J0YW50Ow0KICAgICAgICAgICAgY2xlYXI6IGJvdGggIWltcG9ydGFudDsNCiAgICAgICAgICAgIG1hcmdpbjogMCBhdXRvICFpbXBvcnRhbnQ7DQogICAgICAgICAgICBtYXgtd2lkdGg6IDk4MHB4ICFpbXBvcnRhbnQ7DQogICAgICAgIH0NCiAgICAgICAgDQogICAgICAgIC5jb250YWluZXIgdGFibGUgew0KICAgICAgICAgICAgd2lkdGg6IDEwMCUgIWltcG9ydGFudDsNCiAgICAgICAgICAgIGJvcmRlci1jb2xsYXBzZTogY29sbGFwc2U7DQogICAgICAgIH0NCiAgICAgICAgDQogICAgICAgIC5jb250YWluZXIgLm1hc3RoZWFkIHsNCiAgICAgICAgICAgIHBhZGRpbmc6IDEwcHggMDsNCiAgICAgICAgICAgIGJhY2tncm91bmQ6IHdoaXRlOw0KICAgICAgICAgICAgY29sb3I6IHdoaXRlOw0KICAgICAgICB9DQogICAgICAgIA0KICAgICAgICAuY29udGFpbmVyIC5tYXN0aGVhZCBoMSB7DQogICAgICAgICAgICBtYXJnaW46IDAgYXV0byAhaW1wb3J0YW50Ow0KICAgICAgICAgICAgbWF4LXdpZHRoOiA5MCU7DQogICAgICAgICAgICB0ZXh0LXRyYW5zZm9ybTogdXBwZXJjYXNlOw0KICAgICAgICB9DQogICAgICAgIA0KICAgICAgICAuY29udGFpbmVyIC5jb250ZW50IHsNCiAgICAgICAgICAgIGJhY2tncm91bmQ6IHdoaXRlOw0KICAgICAgICAgICAgcGFkZGluZzogMzBweCAzNXB4Ow0KICAgICAgICB9DQogICAgPC9zdHlsZT4NCjwvaGVhZD4NCg0KPGJvZHk+DQoNCiAgICA8dGFibGUgY2xhc3M9ImNvbnRhaW5lciI+DQoNCiAgICAgICAgPHRyPg0KICAgICAgICAgICAgPHRkIGNsYXNzPSJtYXN0aGVhZCIgc3R5bGU9InBhZGRpbmctbGVmdDogMTAwcHg7IHBhZGRpbmctcmlnaHQ6IDEwMHB4OyI+DQogICAgICAgICAgICAgICAgPGltZyBzcmM9IiMjbG9nbyMjIiBhbHQ9InZhcnNvdmllbm5lIiBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogdHJhbnNwYXJlbnQ7IHRleHQtYWxpZ246IGNlbnRlcjsgd2lkdGg6IDI1JTsgbWFyZ2luLWxlZnQ6IDBweDsgbWFyZ2luLXRvcDogNTBweDsiPjwvaW1nPg0KICAgICAgICAgICAgPC90ZD4NCiAgICAgICAgPC90cj4NCiAgICAgICAgPHRyPg0KICAgICAgICAgICAgPHRkPg0KICAgICAgICAgICAgICAgIDxicj48YnI+PGJyPg0KICAgICAgICAgICAgICAgIDxwIHN0eWxlPSJ0ZXh0LWFsaWduOiBjZW50ZXI7IGZvbnQtd2VpZ2h0OiBib2xkZXI7Ij48dT5DRVJUSUZJQ0FETyBERSBBTlRJR1VFREFEPC91PjwvcD4NCiAgICAgICAgICAgICAgICA8YnI+PGJyPg0KICAgICAgICAgICAgPC90ZD4NCiAgICAgICAgPC90cj4NCiAgICAgICAgPHRyPg0KICAgICAgICAgICAgPHRkIGNsYXNzPSJjb250ZW50IiBzdHlsZT0icGFkZGluZy1sZWZ0OiAxMDBweDsgcGFkZGluZy1yaWdodDogMTAwcHg7IHBhZGRpbmctdG9wOiAwcHg7IHBhZGRpbmctYm90dG9tOiAxMHB4Ij4NCiAgICAgICAgICAgICAgICA8cCBzdHlsZT0idGV4dC1hbGlnbjoganVzdGlmeTsiPg0KICAgICAgICAgICAgICAgICAgICAmbmJzcDsmbmJzcDsmbmJzcDtDZXJ0aWZpY2Ftb3MgcXVlIGRvbigmIzI0MTthKSAjI25vbWJyZXMjIywgYyYjMjMzO2R1bGEgZGUgaWRlbnRpZGFkIG4mIzI1MDttZXJvICMjcnV0IyMgdHJhYmFqYSBlbiBudWVzdHJhIEVtcHJlc2EgZGVzZGUgZWwgIyNmZWNoYV9pbmdyZXNvIyMsIGRlc2VtcGUmIzI0MTsmIzIyNTtuZG9zZSBjb21vICMjbGFib3IjIyBoYXN0YSBsYSBmZWNoYSB5IG1hbnRlbmllbmRvIENvbnRyYXRvIEluZGVmaW5pZG8uDQogICAgICAgICAgICAgICAgPC9wPg0KICAgICAgICAgICAgICAgIDxicj4NCiAgICAgICAgICAgICAgICA8cCBzdHlsZT0idGV4dC1hbGlnbjoganVzdGlmeTsiPiZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwO1NlIGV4dGllbmRlIGVsIHByZXNlbnRlIGNlcnRpZmljYWRvLCBhIHBldGljaSYjMjQzO24gZGVsIFRyYWJhamFkb3IgcGFyYSBsb3MgZmluZXMgcXVlIGVsIGNvbnZlbmdhIHkgYmFqbyBwZXRpY2kmIzI0MztuIHN1eWEsIHNpbiB1bHRlcmlvciByZXNwb25zYWJpbGlkYWQgcGFyYSBsYSBFbXByZXNhLjwvcCBzdHlsZT0idGV4dC1hbGlnbjoganVzdGlmeTsiPg0KICAgICAgICAgICAgPC90ZD4NCiAgICAgICAgPC90cj4NCiAgICAgICAgPHRyPg0KICAgICAgICAgICAgPHRkIGNsYXNzPSJtYXN0aGVhZCIgc3R5bGU9InRleHQtYWxpZ246IGNlbnRlcjsiPg0KICAgICAgICAgICAgICAgIDxpbWcgc3JjPSIjI2Zpcm1hIyMiIGFsdD0iZmlybWEgdmFyc292aWVubmUiIHN0eWxlPSJwb3NpdGlvbjogYWJzb2x1dGU7IGJhY2tncm91bmQtY29sb3I6IHRyYW5zcGFyZW50OyB0ZXh0LWFsaWduOiBjZW50ZXI7IHdpZHRoOiAxNyU7IGxlZnQ6IDUwJTsgcmlnaHQ6IDUwJTsgbWFyZ2luLWxlZnQ6IC0xMjBweDsiPjwvaW1nPg0KICAgICAgICAgICAgPC90ZD4NCiAgICAgICAgPC90cj4NCiAgICAgICAgPHRyPg0KICAgICAgICAgICAgPHRkPg0KICAgICAgICAgICAgICAgIDxicj48YnI+PGJyPg0KICAgICAgICAgICAgICAgIDx0cj4NCiAgICAgICAgICAgICAgICAgICAgPHRkIHN0eWxlPSJ0ZXh0LWFsaWduOiBjZW50ZXI7Zm9udC13ZWlnaHQ6IGJvbGRlcjsiPkJPTUJPTkVTIFZBUlNPVklFTk5FIFMuQS48L3RkPg0KICAgICAgICAgICAgICAgIDwvdHI+DQogICAgICAgICAgICAgICAgPHRyPg0KICAgICAgICAgICAgICAgICAgICA8dGQgc3R5bGU9InRleHQtYWxpZ246IGNlbnRlcjsiPlZpY3RvcmlhIEJydW5lbCBHdWVycmVybzwvdGQ+DQogICAgICAgICAgICAgICAgPC90cj4NCiAgICAgICAgICAgICAgICA8dHI+DQogICAgICAgICAgICAgICAgICAgIDx0ZCBzdHlsZT0idGV4dC1hbGlnbjogY2VudGVyOyI+RW5jYXJnYWRhIGRlIFJlY3Vyc29zIEh1bWFub3M8L3RkPg0KICAgICAgICAgICAgICAgIDwvdHI+DQogICAgICAgICAgICA8L3RkPg0KICAgICAgICA8L3RyPg0KICAgICAgICA8dHI+DQogICAgICAgICAgICA8dGQ+DQogICAgICAgICAgICAgICAgPGJyPjxicj48YnI+PGJyPg0KICAgICAgICAgICAgPC90ZD4NCiAgICAgICAgPC90cj4NCiAgICAgICAgPHRyPg0KICAgICAgICAgICAgPHRkIGNsYXNzPSJjb250ZW50IiBzdHlsZT0icGFkZGluZy1sZWZ0OiAxMDBweDsgcGFkZGluZy1yaWdodDogMTAwcHg7IHBhZGRpbmctdG9wOiAwcHg7IHBhZGRpbmctYm90dG9tOiAxMHB4OyI+DQogICAgICAgICAgICAgICAgPHA+U2FudGlhZ28sICMjZGlhX2hveSMjIGRlICMjbWVzX2hveSMjIGRlICMjYW5ub19ob3kjIzwvcD4NCiAgICAgICAgICAgIDwvdGQ+DQogICAgICAgIDwvdHI+DQogICAgICAgIDx0cj4NCiAgICAgICAgICAgIDx0ZD4NCiAgICAgICAgICAgICAgICA8YnI+DQogICAgICAgICAgICA8L3RkPg0KICAgICAgICA8L3RyPg0KICAgICAgICA8dHI+DQogICAgICAgICAgICA8dGQgY2xhc3M9ImNvbnRlbnQiIHN0eWxlPSJwYWRkaW5nLWxlZnQ6IDEwMHB4OyBwYWRkaW5nLXJpZ2h0OiAxMDBweDsgcGFkZGluZy10b3A6IDBweDsgcGFkZGluZy1ib3R0b206IDEwcHg7Ij4NCiAgICAgICAgICAgICAgICA8cCBzdHlsZT0ibWFyZ2luLWJvdHRvbTogMHB4OyBmb250LXNpemU6IDgwJTsiPkF2LiBFaW5zdGVpbiA3ODcsIFJlY29sZXRhPC9wPg0KICAgICAgICAgICAgICAgIDxwIHN0eWxlPSJtYXJnaW4tYm90dG9tOiAwcHg7IGZvbnQtc2l6ZTogODAlOyI+U2FudGlhZ28sIENoaWxlPC9wPg0KICAgICAgICAgICAgICAgIDxwIHN0eWxlPSJtYXJnaW4tYm90dG9tOiAwcHg7IGZvbnQtc2l6ZTogODAlOyI+VGVsLiArNTYgMiAyNjIxMDk2MDwvcD4NCiAgICAgICAgICAgICAgICA8cCBzdHlsZT0ibWFyZ2luLWJvdHRvbTogMHB4OyBmb250LXNpemU6IDgwJTsiPnd3dy52YXJzb3ZpZW5uZS5jbDwvcD4NCiAgICAgICAgICAgIDwvdGQ+DQogICAgICAgIDwvdHI+DQoNCiAgICA8L3RhYmxlPg0KPC9ib2R5Pg0KDQo8L2h0bWw+')
end;
go

