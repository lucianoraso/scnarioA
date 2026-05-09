const winston = require('winston');

// Definizione dei livelli di log
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Definizione dei colori per i livelli
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'blue',
};

winston.addColors(colors);

// Formato per i log
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => {
      const { timestamp, level, message, ...meta } = info;
      let metaString = '';
      if (Object.keys(meta).length > 0) {
        metaString = JSON.stringify(meta, null, 2);
      }
      return `${timestamp} [QMS] ${level}: ${message} ${metaString}`;
    }
  )
);

// Formato per i log in produzione (JSON)
const productionFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

// Transports
const transports = [
  new winston.transports.Console(),
];

// In produzione, aggiungi file transport
if (process.env.NODE_ENV === 'production') {
  transports.push(
    new winston.transports.File({
      filename: 'logs/qms-error.log',
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    new winston.transports.File({
      filename: 'logs/qms-combined.log',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    })
  );
}

// Creazione del logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  levels,
  format: process.env.NODE_ENV === 'production' ? productionFormat : format,
  transports,
  exitOnError: false,
});

// Stream per Morgan
logger.stream = {
  write: (message) => {
    logger.http(message.trim());
  },
};

module.exports = logger;

// Made with Bob
