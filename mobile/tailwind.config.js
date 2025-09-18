/** @type {import('tailwindcss').Config} */
module.exports = {
  // NOTE: Update this to include the paths to all of your component files.
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        customBg: "#fb565a", // buttons bg color
        cardBg: "#edebec", // card bg color
        customText: "#C44545", // text color
      },
    },
  },
  plugins: [],
};
