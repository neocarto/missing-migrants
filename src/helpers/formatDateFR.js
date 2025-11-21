export function formatDateFR(dateStr) {
  const mois = [
    "janvier",
    "février",
    "mars",
    "avril",
    "mai",
    "juin",
    "juillet",
    "août",
    "septembre",
    "octobre",
    "novembre",
    "décembre",
  ];

  const [year, month, day] = dateStr.split("-").map(Number);
  return `${day} ${mois[month - 1]} ${year}`;
}
