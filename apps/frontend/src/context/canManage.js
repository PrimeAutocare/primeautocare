export function canManage(employee, allowedRoles) {
  if (!employee) return false;
  return allowedRoles.includes(employee.emp_role);
}
