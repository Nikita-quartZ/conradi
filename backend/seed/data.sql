-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Хост: MySQL-8.2
-- Время создания: Янв 24 2026 г., 01:25
-- Версия сервера: 8.2.0
-- Версия PHP: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `conradi`
--

-- --------------------------------------------------------

--
-- Структура таблицы `cart`
--

CREATE TABLE `cart` (
  `id` int NOT NULL,
  `cost` decimal(10,2) NOT NULL,
  `amount` int NOT NULL,
  `user_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `cart_item`
--

CREATE TABLE `cart_item` (
  `id` int NOT NULL,
  `cart_id` int NOT NULL,
  `product_id` int NOT NULL,
  `cost` decimal(10,2) NOT NULL,
  `amount` int NOT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `category`
--

CREATE TABLE `category` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `category`
--

INSERT INTO `category` (`id`, `title`) VALUES
(2, 'Авторские'),
(3, 'Монобукеты'),
(4, 'Букеты невесты'),
(5, 'Цветы в корзине'),
(6, 'Композиции из цветов'),
(7, 'Цветы для интерьера');

-- --------------------------------------------------------

--
-- Структура таблицы `estimation_user`
--

CREATE TABLE `estimation_user` (
  `id` int NOT NULL,
  `estimation` decimal(8,1) NOT NULL DEFAULT '0.0',
  `user_id` int NOT NULL,
  `product_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `image`
--

CREATE TABLE `image` (
  `id` int NOT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `product_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `image`
--

INSERT INTO `image` (`id`, `image`, `product_id`) VALUES
(5, '1769194086_OVagHoWiHXSwqKg84lHji12XtOXVPTlC.jpg', 13),
(6, '1769194241_KZvc9B_SfUZkZePm4O7z4cQTHdP3Ae-w.jpg', 12),
(7, '1769194371_qKC25EXo32CJPW8e-AUJNNwMb9fpeClG.jpg', 11),
(8, '1769194541_dw46R4WdLqjbM637noxYbjuh6bqyzQ4R.jpg', 10),
(9, '1769195760_lv020PRjaLJu0ohnu-_NK7JrtDw7VsF_.jpg', 9),
(10, '1769195901_QszsM1nM3EBIg7QFsFy8Cf5ZnBhVB6Mt.jpg', 8),
(11, '1769196020_mpMyPSo1QOEFmpt52Do2Rqa82C6Opus0.jpg', 7),
(12, '1769196127_sdWTgBnxBTJQIhgxn7lMAlFz0vnJUZLW.jpg', 6),
(13, '1769196491_FVMFcJbHjymJS4bZjbATL5UKBpcquKfk.jpg', 14),
(14, '1769196981_COUcFiEn3qOCEHlOFkAB-LDl4o7F2CW2.jpg', 15),
(15, '1769197070_Zn1wmHZKHEmVXDeUbTMqAtsR0LQC43Fn.jpg', 16),
(16, '1769197235_EHDXGJx7IQrTt1HhhbMYkptzlpWvos5W.jpg', 17),
(17, '1769197308_Mj08Bg5tFVQblu4SqgBiqOAp5zbCqN51.jpg', 18),
(18, '1769197392_ViS1ZVnq90qPCPNk61KC-7rqHfCltTUL.jpg', 19),
(19, '1769197453_Q7QMg0YJ69rCvO5vpDd0nRprtYKPi9P0.jpg', 20),
(20, '1769197544_UnYOnNbIR96o01QUnuCSj_VIciA0JZI_.jpg', 21),
(21, '1769203131_W-f23pDLhwzmkOzvzro4V8MEdCQByKSy.jpg', 22),
(22, '1769203202_CPBZJqE38wNszy9_KB9yIkNNEzLAoib-.jpg', 23),
(23, '1769203270_vcTjE6CGtEkQUEF07lyVIAEC4_jhbE1t.jpg', 24),
(24, '1769203393_xQqBnNZ_EpwDYmAXYQtNHL-tZmBhPnOk.jpg', 25),
(25, '1769203515_6LAGevzlvbCoDgbFpU9yqvKjwsbNWDAE.jpg', 26),
(26, '1769203607_2fligtkjI7FCtzWdgUkAIauuXxA87-4Z.jpg', 27),
(27, '1769203716_4uO7IRvJGrmLSqWleAPz0iNSTZjmmBVC.jpg', 28),
(28, '1769203773_429U0b7n926p0jLp9_qwC8hfPJueKpEj.jpg', 29),
(29, '1769203955_VwgNd3HzU9fbL7c88WbWSMXroGc-ESnp.jpg', 30),
(30, '1769204065_5ySz2CYUkjwrJUJEa7UHI-_Rxpi7YNk5.jpg', 31),
(31, '1769204289_7U8aK_C_Eq6d4_JsXGflzHfiAusVf1-B.jpg', 32),
(32, '1769204394_MOSpISiqA-uv4CgCySSk3hdVIHv-hiNr.jpg', 33),
(33, '1769204516_u_a83H9QJJCCl2AtRbxnkpdtq8PkF62x.jpg', 34),
(34, '1769204632_A0Osk-t0KwHEGn9WcDABAiU_TTAAiD83.jpg', 35),
(35, '1769204742_PlChiBInSoiDcPCnoJ1aM2f9V5hFQ4OV.jpg', 36),
(36, '1769204743_nsrRt9ZtIctKLdzyt8Bs0z1rZvDXAjrQ.jpg', 37),
(37, '1769204965_CYWg0UDh1oc7rl1UfMN-jWNVqjOlma28.jpg', 38),
(38, '1769205085_qksxOiEmznoha829YhaGDyRbI0e3uID9.jpg', 39),
(39, '1769205169_zjr865MGdHx0ktBfmmFHO_CQXvow32Oe.jpg', 40),
(40, '1769205258_-zEIbKQBp-CY_PEAFPDduIKCzQpbVshq.jpg', 41),
(41, '1769205378_1mpzhgYaGyQCmXcr8L4i8m3SaNLzMGLv.jpg', 42),
(42, '1769205501_S860ixNgkv9KjiVo67dz9emL_Hf7wMam.jpg', 43),
(43, '1769205639_ge4LlIHMJWrD-mCHHQvyLHhsS2sMJc2Y.jpg', 44),
(44, '1769205762_lYeGOB4GmZ34rDdhtW0opLovNsw0taZj.jpg', 45),
(45, '1769205853_7OjkFXiyVEJ3dYh3PvSmBOhS4HjCPf_z.jpg', 46),
(46, '1769205974_uAoA621xzQW3jvNtiPiKtN_p72twZBu-.jpg', 47),
(47, '1769206053_9lUAmd84Sw_ol0s0ektfHtZ-mY7KEANh.jpg', 48),
(48, '1769206232_Nm15_K_YgFfyhc83c5wJzoKQwVfa__Or.jpg', 49),
(49, '1769206339_NbsP9FVsQBosLkqYcj_h75qngkjM3l86.jpg', 50),
(50, '1769206427_28CuZ61igplQ7Ud6AifkbmU5JuYUy3sx.jpg', 51),
(51, '1769206514_cFS9dXgXZXZLL3PpAZCuoBoSZSNX-ReG.jpg', 52),
(52, '1769206639_QDfAL8ShBG3y6f_dw6nLJBi-a7_ry5qG.jpg', 53),
(53, '1769206756_vrvJwK7DOWQI8pQ04B36AmMNKA_jsu1A.jpg', 54);

-- --------------------------------------------------------

--
-- Структура таблицы `order`
--

CREATE TABLE `order` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `amount` int NOT NULL,
  `pay_type_id` int NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status_id` int NOT NULL,
  `date_time` datetime NOT NULL,
  `created_at` timestamp NOT NULL,
  `pay_receipt` tinyint NOT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `order_item`
--

CREATE TABLE `order_item` (
  `id` int NOT NULL,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `amount` int NOT NULL,
  `cost` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `pay_type`
--

CREATE TABLE `pay_type` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `online` tinyint NOT NULL,
  `place` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `product`
--

CREATE TABLE `product` (
  `id` int NOT NULL,
  `category_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `stars` decimal(8,1) NOT NULL DEFAULT '0.0',
  `price` decimal(10,0) NOT NULL DEFAULT '0',
  `desciption` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `count` int NOT NULL,
  `product_type_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `product`
--

INSERT INTO `product` (`id`, `category_id`, `title`, `stars`, `price`, `desciption`, `count`, `product_type_id`) VALUES
(6, 2, 'Букет «Кружево»', 0.0, 2993, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 4 шт.\r\nУпаковка дизайнерская - 1 шт.\r\nФранцузская роза - 3 шт.', 20, 3),
(7, 2, 'Букет «Ноктюрн»', 0.0, 2464, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 4 шт.\r\nЛента атласная - 1 шт.\r\nТишью - 2 шт.\r\nДиантус - 11 шт.\r\nФоамиран (упаковка) - 1 шт.', 20, 3),
(8, 2, 'Букет «Клубничное мороженое»', 0.0, 2373, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nГипсофила - 1 шт.\r\nЛента атласная - 1 шт.\r\nТишью - 1 шт.\r\nПионовидная кустовая роза - 3 шт.\r\nФоамиран (упаковка) - 1 шт.', 20, 3),
(9, 2, 'Букет «Marshmallow»', 0.0, 2850, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 4 шт.\r\nЛента атласная - 1 шт.\r\nТишью - 2 шт.\r\nФранцузская роза - 3 шт.\r\nФоамиран (упаковка) - 1 шт.', 20, 3),
(10, 2, 'Букет «Голубая Лагуна»', 0.0, 2482, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nГортензия - 1 шт.\r\nХризантема кустовая - 1 шт.\r\nЭвкалипт - 1 шт.\r\nУпаковка дизайнерская - 3 шт.\r\nХризантема ньютон - 1 шт.', 20, 3),
(11, 2, 'Букет \"Пламенные чувства\"', 0.0, 2700, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nРоза красная - 9 шт.\r\nОрхидея дендробиум синяя - 8 шт.\r\nКолба для орхидеи - 8 шт.', 20, 3),
(12, 2, 'Букет \"Ты мой космос\"', 0.0, 1925, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nГипсофила - 3 шт.\r\nорхидея - 7 шт.\r\nУпаковка дизайнерская - 1 шт.\r\nколбы для орхидея - 7 шт.', 20, 3),
(13, 2, 'Букет «Бриджит Джонс»', 0.0, 2963, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nРоза кустовая пионовидная - 3 шт.\r\nУпаковка дизайнерская - 1 шт.\r\nЭвкалипт Цинерея - 3 шт.\r\nДиантус конфетный - 3 шт.\r\n', 20, 3),
(14, 3, 'Букет \"One Love\"', 0.0, 2485, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЛента атласная - 2 шт.\r\nУпаковка дизайнерская - 1 шт.\r\nроза красная 40 см - 19 шт.', 20, 3),
(15, 3, 'Букет \"Бомбастик\"', 0.0, 3627, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЭвкалипт - 2 шт.\r\nУпаковка дизайнерская - 4 шт.\r\nкустовые пион розы 40 см - 9 шт.', 20, 3),
(16, 3, 'Букет \"Нежность\"', 0.0, 2984, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 11 шт.\r\nЛента атласная - 1 шт.\r\nСтильная упаковка - 3 шт.\r\nработа флориста - 1 шт.', 20, 3),
(17, 3, 'Букет \"Персиковый куст\"', 0.0, 2999, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nХризантема кустовая - 5 шт.\r\nЛента атласная - 1 шт.\r\nТишью - 2 шт.\r\nПленка - 3 шт.', 20, 3),
(18, 3, 'Букет \"Пудровый рай\"', 0.0, 2125, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nХризантема кустовая - 3 шт.\r\nЛента атласная - 1 шт.\r\nТишью - 2 шт.\r\nПленка матовая - 2 шт.', 20, 3),
(19, 3, 'Букет \"Сильва Пинк\"', 0.0, 2980, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЛента атласная - 1 шт.\r\nТишью - 2 шт.\r\nПленка матовая - 2 шт.\r\nРоза кустовая пионовидная silva pink - 7 шт.', 20, 3),
(20, 3, 'Букет \"Твое сердце\"', 0.0, 5496, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЛента атласная - 1 шт.\r\nФисташка - 5 шт.\r\nУпаковка дизайнерская - 2 шт.\r\nФранцузская роза - 9 шт.', 20, 3),
(21, 3, 'Букет \"Хлопок Виола\"', 0.0, 1975, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nХлопок - 3 шт.\r\nХризантема кустовая - 3 шт.\r\nЛента атласная - 1 шт.\r\nТишью - 1 шт.\r\nПленка дизайнерская - 2 шт.', 20, 3),
(22, 4, 'Букет \"Вечная любовь\"', 0.0, 6427, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nСостав\r\nЛаванда - 37 шт.\r\nХлопок - 7 шт.\r\nПшеница - 45 шт.', 20, 3),
(23, 4, 'Букет \"Воздушная гипсофила\"', 0.0, 4300, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nГипсофила - 9 шт.\r\nЭвкалипт - 2 шт.\r\nЛента атласная - 4 шт.', 20, 3),
(24, 4, 'Букет \"Диантус\"', 0.0, 7505, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nДиантус - 39 шт.', 20, 3),
(25, 4, 'Букет \"Доверие\"', 0.0, 4858, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nГипсофила - 1 шт.\r\nЭвкалипт - 5 шт.\r\nЛента атласная - 5 шт.\r\nДиантусы сортовые (гвоздики) - 11 шт.', 20, 3),
(26, 4, 'Букет \"Искра\"', 0.0, 3393, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nГипсофила - 7 шт.', 20, 3),
(27, 4, 'Букет \"Калла\"', 0.0, 12800, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nКалла - 19 шт.\r\nЛента атласная - 4 шт.', 20, 3),
(28, 4, 'Букет \"Нежная альстромерия\"', 0.0, 5154, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 17 шт.', 20, 3),
(29, 4, 'Букет \"Счастливый брак\"', 0.0, 6122, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЛента атласная белая - 1 шт.\r\nлизиантус (эустома) белый - 7 шт.', 20, 3),
(30, 5, 'Букет \"Пионикс\"', 0.0, 3980, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЭвкалипт - 2 шт.\r\nТишью - 1 шт.\r\nАтласная лента - 1 шт.\r\nДиантус розовый - 5 шт.\r\nОазис флористический - 1 шт.\r\nМенсфилд парк кустовая пионовидная - 3 шт.\r\nКорзина круглая s - 1 шт.', 20, 3),
(31, 5, 'Букет \"Поехали\"', 0.0, 5990, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nКорзина - 1 шт.\r\nЛента атласная - 1 шт.\r\nОазис флористический - 1 шт.\r\nОрхидей дендробиум - 35 шт.', 20, 3),
(32, 5, 'Букет \"Весенний порыв\"', 0.0, 6072, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nХризантема кустовая - 10 шт.\r\nЛента атласная - 1 шт.\r\nКорзина плетеная - 1 шт.\r\nОазис флористический - 2 шт.', 20, 3),
(33, 5, 'Букет \"Француженка\"', 0.0, 6490, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЭвкалипт - 2 шт.\r\nОазис - 2 шт.\r\nФранцузская роза - 7 шт.\r\nБусы декоративные - 1 шт.\r\nКорзина джутовая - 1 шт.', 20, 3),
(34, 5, 'Букет \"Мур-мур\"', 0.0, 5742, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nХризантема кустовая - 3 шт.\r\nЭустома - 2 шт.\r\nРоза кустовая пионовидная - 4 шт.\r\nКорзина плетеная - 1 шт.\r\nЗелень декоративная - 5 шт.', 20, 3),
(35, 5, 'Букет \"База\"', 0.0, 6423, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nРускус - 4 шт.\r\nКорзина плетеная - 1 шт.\r\nОазис флористический - 1 шт.\r\nРоза кения - 25 шт.', 20, 3),
(36, 5, 'Букет \"Аля-рус\"', 0.0, 6675, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАмариллис - 2 шт.\r\nГиперикум - 2 шт.\r\nЭвкалипт - 3 шт.\r\nСантини - 3 шт.\r\nТуя - 2 шт.\r\nКорзина и оазис - 1 шт.', 20, 3),
(37, 5, 'Букет \"Аля-рус\"', 0.0, 6675, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАмариллис - 2 шт.\r\nГиперикум - 2 шт.\r\nЭвкалипт - 3 шт.\r\nСантини - 3 шт.\r\nТуя - 2 шт.\r\nКорзина и оазис - 1 шт.', 20, 3),
(38, 5, 'Букет \"Pink Basket\"', 0.0, 4455, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЛизиантус - 2 шт.\r\nЛента атласная - 1 шт.\r\nДиантус - 1 шт.\r\nЦимбидиум - 1 шт.\r\nКорзина плетеная - 1 шт.\r\nБомбастик - 1 шт.\r\nЭвкалипт Микс - 3 шт.\r\nОазис флористический - 1 шт.\r\nЭквадор роза - 1 шт.\r\nNewton хризантема - 2 шт.', 20, 3),
(39, 6, 'Букет \"Без лишних слов\"', 0.0, 4585, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nКонфеты Raffaello - 7 шт.\r\nРоза кустовая розовая - 4 шт.\r\nКоробка - 1 шт.\r\nГипсофила Белая - 2 шт.', 20, 3),
(40, 6, 'Букет \"Моей звездочке\"', 0.0, 3705, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nХризантема кустовая - 5 шт.\r\nПлайм пакет - 1 шт.\r\nДендробиум - 6 шт.\r\nОазис флористический - 1 шт.', 20, 3),
(41, 6, 'Букет \"Балу\"', 0.0, 4755, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЭвкалипт - 4 шт.\r\nУпаковка - 1 шт.\r\nКоробка - 1 шт.\r\nФранцузская роза - 3 шт.\r\nПакет подарочный - 1 шт.\r\nМишка плюшевый - 1 шт.\r\nОазис флористический - 1 шт.', 20, 3),
(42, 6, 'Букет \"Аврора\"', 0.0, 22500, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАспидистра - 8 шт.\r\nКорзина - 1 шт.\r\nКустовая роза - 10 шт.\r\nЭустома - 3 шт.\r\nПленка - 1 шт.\r\nЛепестки - 17 шт.\r\nОазис - 2 шт.\r\nШпагат - 1 шт.\r\nРобелини - 3 шт.\r\nДекор - 10 шт.\r\nБулавка - 5 шт.\r\nКлей - 1 шт.\r\nРоза штучная - 10 шт.\r\nМачта - 3 шт.', 20, 3),
(43, 6, 'Букет \"Frash flower\"', 0.0, 3840, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 1 шт.\r\nЭустома - 2 шт.\r\nДиантус - 1 шт.\r\nФранцузская роза - 1 шт.\r\nЛагурус - 5 шт.\r\nОазис флористический - 1 шт.\r\nСумка для цветов - 1 шт.', 20, 3),
(44, 6, 'Букет \"Роса\"', 0.0, 1447, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 1 шт.\r\nЛимониум - 1 шт.\r\nСтатица - 1 шт.\r\nТишью - 1 шт.\r\nОазис флористический - 1 шт.\r\nГвоздика кустовая Белая - 1 шт.\r\nАлтай хризантема - 1 шт.\r\nДелигрин - 1 шт.\r\nСумочка с ручками из плотного картона ламинированного - 1 шт.\r\nЛинди сантини - 1 шт.\r\nВегги роза - 1 шт.', 20, 3),
(45, 6, 'Букет \"50 оттенков фиолетового\"', 0.0, 2250, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nЛимониум - 1 шт.\r\nФисташка - 1 шт.\r\nБрассика - 1 шт.\r\nЭвкалипт пучок - 1 шт.\r\nЛунный диантус - 6 шт.\r\nСумка с оазисом - 1 шт.', 20, 3),
(46, 6, 'Букет \"Порфавор\"', 0.0, 2800, 'УХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nСОСТАВ:\r\nАльстромерия - 2 шт.\r\nЛимониум - 1 шт.\r\nФисташка - 1 шт.\r\nЭвкалипт Парвифолия - 1 шт.\r\nРоза французская - 1 шт.\r\nОазис флористический - 1 шт.\r\nСумочка картонная - 1 шт.', 20, 3),
(47, 7, 'Цветок \"Протея\"', 0.0, 1900, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА- 40 см', 100, 4),
(48, 7, 'Цветок \"Альстромерия\"', 0.0, 445, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА- 50 см', 100, 4),
(49, 7, 'Цветок \"Илекс\"', 0.0, 1641, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА - 45 см', 100, 4),
(50, 7, 'Цветок \"Орнитогалум\"', 0.0, 450, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА - 35 см', 100, 4),
(51, 7, 'Цветок \"Красная роза\"', 0.0, 430, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА - 60 см', 100, 4),
(52, 7, 'Цветок \"Белая роза\"', 0.0, 383, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА - 60 см', 100, 4),
(53, 7, 'Цветок \"Розовая гвоздика', 0.0, 298, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА - 40 см', 100, 4),
(54, 7, 'Цветок \"Французская роза\"', 0.0, 499, 'ЦЕНА за 1 шт\r\n\r\nУХОД:\r\n▪️ Подрежьте стебли под углом перед тем, как поставить в вазу.\r\n▪️ Меняйте воду каждые 2–3 дня и берегите букет от прямого солнца.\r\n▪️ Удаляйте увядшие бутоны, чтобы продлить свежесть и настроение.\r\n\r\nВЫСОТА - 70 см', 100, 4);

-- --------------------------------------------------------

--
-- Структура таблицы `product_type`
--

CREATE TABLE `product_type` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `product_type`
--

INSERT INTO `product_type` (`id`, `title`) VALUES
(3, 'Букет'),
(4, 'Цветок');

-- --------------------------------------------------------

--
-- Структура таблицы `role`
--

CREATE TABLE `role` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `role`
--

INSERT INTO `role` (`id`, `title`) VALUES
(1, 'admin'),
(2, 'user');

-- --------------------------------------------------------

--
-- Структура таблицы `status`
--

CREATE TABLE `status` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `status`
--

INSERT INTO `status` (`id`, `title`) VALUES
(1, 'Создан'),
(2, 'В сборке'),
(3, 'Доставлен'),
(4, 'Отменен'),
(5, 'Оплачен онлайн'),
(6, 'Ожидает оплаты'),
(7, 'Оплата при получении'),
(8, 'Оплачен оффлайн'),
(9, 'Заказ выдан');

-- --------------------------------------------------------

--
-- Структура таблицы `subscribe`
--

CREATE TABLE `subscribe` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `user`
--

CREATE TABLE `user` (
  `id` int NOT NULL,
  `full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `login` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `birthday` date NOT NULL,
  `role_id` int NOT NULL DEFAULT '0',
  `auth_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `user`
--

INSERT INTO `user` (`id`, `full_name`, `login`, `password`, `phone`, `birthday`, `role_id`, `auth_key`) VALUES
(7, 'Иванов Иван Иванович', 'User12', '$2y$13$s0vfIfmxh1Zw/8z7iY8PAuy5bsl4GBCuZGTJX2.1YWSf.A4ElDN7O', '8(111)111-11-11', '2000-03-12', 2, 'mQm15Q9pyUw00X4kLkAMw057P_f1vkpO'),
(10, 'Админ Админ Админ', 'Admin12', '$2y$13$HgCkX9UditvT6VJ7EXkmsO52i/3PMaDCcpk5jvUMZZNz7ZZJtpfFS', '8(345)345-34-53', '2000-05-31', 1, '5bz4qI8AbI3Pph0b65n4H1qv02rnGlo-');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `cart_item`
--
ALTER TABLE `cart_item`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `basket_id` (`cart_id`);

--
-- Индексы таблицы `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `estimation_user`
--
ALTER TABLE `estimation_user`
  ADD KEY `product_id` (`product_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `image`
--
ALTER TABLE `image`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_id` (`product_id`);

--
-- Индексы таблицы `order`
--
ALTER TABLE `order`
  ADD PRIMARY KEY (`id`),
  ADD KEY `status_id` (`status_id`),
  ADD KEY `type_pay_id` (`pay_type_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `order_item`
--
ALTER TABLE `order_item`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Индексы таблицы `pay_type`
--
ALTER TABLE `pay_type`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `type_product_id` (`product_type_id`);

--
-- Индексы таблицы `product_type`
--
ALTER TABLE `product_type`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `subscribe`
--
ALTER TABLE `subscribe`
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `login` (`login`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD KEY `role_id` (`role_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `cart_item`
--
ALTER TABLE `cart_item`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `category`
--
ALTER TABLE `category`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT для таблицы `image`
--
ALTER TABLE `image`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT для таблицы `order`
--
ALTER TABLE `order`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `order_item`
--
ALTER TABLE `order_item`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `pay_type`
--
ALTER TABLE `pay_type`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `product`
--
ALTER TABLE `product`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT для таблицы `product_type`
--
ALTER TABLE `product_type`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT для таблицы `role`
--
ALTER TABLE `role`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `user`
--
ALTER TABLE `user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

--
-- Ограничения внешнего ключа таблицы `cart_item`
--
ALTER TABLE `cart_item`
  ADD CONSTRAINT `cart_item_ibfk_2` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  ADD CONSTRAINT `cart_item_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `estimation_user`
--
ALTER TABLE `estimation_user`
  ADD CONSTRAINT `estimation_user_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `estimation_user_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `image`
--
ALTER TABLE `image`
  ADD CONSTRAINT `image_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `order`
--
ALTER TABLE `order`
  ADD CONSTRAINT `order_ibfk_1` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  ADD CONSTRAINT `order_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  ADD CONSTRAINT `order_ibfk_4` FOREIGN KEY (`pay_type_id`) REFERENCES `pay_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `order_item`
--
ALTER TABLE `order_item`
  ADD CONSTRAINT `order_item_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  ADD CONSTRAINT `order_item_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Ограничения внешнего ключа таблицы `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  ADD CONSTRAINT `product_ibfk_3` FOREIGN KEY (`product_type_id`) REFERENCES `product_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `subscribe`
--
ALTER TABLE `subscribe`
  ADD CONSTRAINT `subscribe_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

--
-- Ограничения внешнего ключа таблицы `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
