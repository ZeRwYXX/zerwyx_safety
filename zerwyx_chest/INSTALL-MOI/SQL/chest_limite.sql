

CREATE TABLE `zerwyx_chest` (
  `id` int(11) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `heading` float NOT NULL,
  `code` varchar(10) NOT NULL,
  `identifier` varchar(46) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

ALTER TABLE `zerwyx_chest`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;
COMMIT;

INSERT INTO `items` (`name`, `label`, `limite`, `rare`, `can_remove`) VALUES
('chest', 'Coffre Fort', 1, 0, 1);