const { colors } = require("tailwindcss/defaultTheme");

const primary = "#2274A5";
const primaryLight = "#56abdc";
const primaryDark = "#113c55";
module.exports = {
  purge: ["./_site/*.html", "./site/*.html.eex"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      typography: {
        primary: {
          css: {
            a: {
              color: primary,
              "&:hover": {
                color: primaryLight,
              },
              "&:visted": {
                color: primaryDark,
              },
            },
            pre: {
              backgroundColor: "#EEF7FC",
              color: "#222",
            },
          },
        },
      },
      colors: {
        primary: primary,
        "primary-light": primaryLight,
        "primary-dark": primaryDark,
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/typography")],
};
