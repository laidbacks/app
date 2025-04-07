module.exports = {
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/test/javascript'],
  moduleFileExtensions: ['js', 'jsx'],
  transform: {
    '^.+\\.(js|jsx)$': 'babel-jest',
  },
  setupFilesAfterEnv: ['<rootDir>/test/javascript/setup.js'],
}; 