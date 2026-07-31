ALTER TABLE `usuario_preferencia`
    ADD COLUMN `calendario_visao` VARCHAR(20) DEFAULT 'dayGridMonth' COMMENT 'dayGridMonth|dayGridWeek' AFTER `calendario_eventos`;
