public class CommonsModule implements DI.IServiceProvider {
    public static Object getService(Type serviceType) {
        return provider.getService(serviceType);
    }

    public static List<Object> getServices(Type serviceType) {
        return provider.getServices(serviceType);
    }

    public static DI.IServiceProvider provider {
        get {
            if (provider == null) {
                provider = new DI.ServiceCollection()
                    .addTransient(LogEventHandler.class, LogEventHandler.class)
                    .buildServiceProvider();
            }
            return provider;
        }
        set;
    }
}
