package sayableage;

public sealed interface StageLabel {

    String resolve(String gender);

    record Neutral(String label) implements StageLabel {
        @Override
        public String resolve(String gender) {
            return label;
        }
    }

    record Gendered(String m, String f) implements StageLabel {
        @Override
        public String resolve(String gender) {
            return "f".equals(gender) ? f : m;
        }
    }

    static StageLabel neutral(String label) {
        return new Neutral(label);
    }

    static StageLabel gendered(String m, String f) {
        return new Gendered(m, f);
    }
}
