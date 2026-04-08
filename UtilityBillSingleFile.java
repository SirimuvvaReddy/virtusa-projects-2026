import java.util.InputMismatchException;
import java.util.Scanner;

interface Billable {
    double calculateTotal();
}

class UtilityBill implements Billable {
    private String customerName;
    private int previousReading;
    private int currentReading;
    private int unitsConsumed;
    private double ratePerUnit;
    private double taxAmount;
    private double finalTotal;

    public UtilityBill(String customerName, int previousReading, int currentReading) {
        this.customerName = customerName;
        this.previousReading = previousReading;
        this.currentReading = currentReading;
        this.unitsConsumed = currentReading - previousReading;
    }

    public double calculateTotal() {
        if (unitsConsumed >= 0 && unitsConsumed <= 100) {
            ratePerUnit = 1.00;
        } else if (unitsConsumed <= 300) {
            ratePerUnit = 2.00;
        } else {
            ratePerUnit = 5.00;
        }

        double baseAmount = unitsConsumed * ratePerUnit;
        taxAmount = baseAmount * 0.10;
        finalTotal = baseAmount + taxAmount;
        return finalTotal;
    }

    public void printReceipt() {
        System.out.println();
        System.out.println("========== Digital Receipt ==========");
        System.out.println("Customer Name : " + customerName);
        System.out.println("Units Consumed: " + unitsConsumed);
        System.out.println("Tax Amount    : $" + String.format("%.2f", taxAmount));
        System.out.println("Final Total   : $" + String.format("%.2f", finalTotal));
        System.out.println("=====================================");
        System.out.println();
    }
}

public class UtilityBillSingleFile {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Municipality Utility Bill Generator");
        System.out.println("Type Exit as customer name to stop the program.");

        while (true) {
            System.out.print("\nEnter customer name: ");
            String customerName = scanner.nextLine();

            if (customerName.equalsIgnoreCase("Exit")) {
                System.out.println("Program closed.");
                break;
            }

            int previousReading = readReading(scanner, "Enter previous meter reading: ");
            int currentReading = readReading(scanner, "Enter current meter reading: ");

            if (previousReading > currentReading) {
                System.out.println("Error: Previous meter reading cannot be higher than current meter reading.");
                continue;
            }

            UtilityBill bill = new UtilityBill(customerName, previousReading, currentReading);
            bill.calculateTotal();
            bill.printReceipt();
        }

        scanner.close();
    }

    private static int readReading(Scanner scanner, String message) {
        while (true) {
            try {
                System.out.print(message);
                int reading = scanner.nextInt();
                scanner.nextLine();

                if (reading < 0) {
                    System.out.println("Reading cannot be negative.");
                    continue;
                }

                return reading;
            } catch (InputMismatchException e) {
                System.out.println("Please enter a valid whole number.");
                scanner.nextLine();
            }
        }
    }
}
